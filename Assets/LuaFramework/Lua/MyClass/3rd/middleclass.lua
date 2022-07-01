local middleclass = {
    _VERSION     = 'middleclass v4.1.1',
    _DESCRIPTION = 'Object Orientation for Lua',
    _URL         = 'https://github.com/kikito/middleclass',
    _LICENSE     = [[
    MIT LICENSE

    Copyright (c) 2011 Enrique García Cota

    特此免费授予任何获得
    本软件和相关文档文件的副本（
    “软件”），不受限制地处理软件，包括
    不限于使用、复制、修改、合并、发布的权利，
    分发、再许可和/或出售软件的副本，以及
    允许向其提供软件的人这样做，但须遵守
    以下条件：

    应包括上述版权声明和本许可声明
    在软件的所有副本或主要部分中。

    本软件按“原样”提供，不提供任何形式的明示保证
    或暗示的，包括但不限于
    适销性、特定用途的适用性和非侵权性。
    在任何情况下，作者或版权所有者均不对任何
    索赔、损害赔偿或其他责任，无论是在合同诉讼中，
    侵权或其他原因，由
    软件或软件中的使用或其他交易。
  ]]
}

local function _createIndexWrapper(aClass, f)
    if f == nil then
        return aClass.__instanceDict
    else
        return function(self, name)
            local value = aClass.__instanceDict[name]

            if value ~= nil then
                return value
            elseif type(f) == "function" then
                return (f(self, name))
            else
                return f[name]
            end
        end
    end
end

local function _propagateInstanceMethod(aClass, name, f)
    f = name == "__index" and _createIndexWrapper(aClass, f) or f
    aClass.__instanceDict[name] = f

    for subclass in pairs(aClass.subclasses) do
        if rawget(subclass.__declaredMethods, name) == nil then
            _propagateInstanceMethod(subclass, name, f)
        end
    end
end

local function _declareInstanceMethod(aClass, name, f)
    aClass.__declaredMethods[name] = f

    if f == nil and aClass.super then
        f = aClass.super.__instanceDict[name]
    end

    _propagateInstanceMethod(aClass, name, f)
end

local function _tostring(self) return "class " .. self.name end
local function _call(self, ...) return self:new(...) end

local function _createClass(name, super)
    local dict = {}
    dict.__index = dict

    local aClass = { name = name, super = super, static = {},
                     __instanceDict = dict, __declaredMethods = {},
                     subclasses = setmetatable({}, {__mode='k'})  }

    if super then
        setmetatable(aClass.static, {
            __index = function(_,k)
                local result = rawget(dict,k)
                if result == nil then
                    return super.static[k]
                end
                return result
            end
        })
    else
        setmetatable(aClass.static, { __index = function(_,k) return rawget(dict,k) end })
    end

    setmetatable(aClass, { __index = aClass.static, __tostring = _tostring,
                           __call = _call, __newindex = _declareInstanceMethod })

    return aClass
end

local function _includeMixin(aClass, mixin)
    assert(type(mixin) == 'table', "mixin must be a table")

    for name,method in pairs(mixin) do
        if name ~= "included" and name ~= "static" then aClass[name] = method end
    end

    for name,method in pairs(mixin.static or {}) do
        aClass.static[name] = method
    end

    if type(mixin.included)=="function" then mixin:included(aClass) end
    return aClass
end

local DefaultMixin = {
    __tostring   = function(self) return "instance of " .. tostring(self.class) end,

    initialize   = function(self, ...) end,

    isInstanceOf = function(self, aClass)
        return type(aClass) == 'table'
                and type(self) == 'table'
                and (self.class == aClass
                or type(self.class) == 'table'
                and type(self.class.isSubclassOf) == 'function'
                and self.class:isSubclassOf(aClass))
    end,

    static = {
        allocate = function(self)
            assert(type(self) == 'table', "确保您使用的是 'Class:allocate' 而不是 'Class.allocate'")
            return setmetatable({ class = self }, self.__instanceDict)
        end,

        new = function(self, ...)
            assert(type(self) == 'table', "确保您使用的是 'Class:new' 而不是 'Class.new'")
            local instance = self:allocate()
            instance:initialize(...)
            return instance
        end,

        subclass = function(self, name)
            assert(type(self) == 'table', "确保您使用的是 'Class:subclass' 而不是 'Class.subclass'")
            assert(type(name) == "string", "您必须为您的类提供名称（字符串）")

            local subclass = _createClass(name, self)

            for methodName, f in pairs(self.__instanceDict) do
                _propagateInstanceMethod(subclass, methodName, f)
            end
            subclass.initialize = function(instance, ...) return self.initialize(instance, ...) end

            self.subclasses[subclass] = true
            self:subclassed(subclass)

            return subclass
        end,

        subclassed = function(self, other) end,

        isSubclassOf = function(self, other)
            return type(other)      == 'table' and
                    type(self.super) == 'table' and
                    ( self.super == other or self.super:isSubclassOf(other) )
        end,

        include = function(self, ...)
            assert(type(self) == 'table', "Make sure you that you are using 'Class:include' instead of 'Class.include'")
            for _,mixin in ipairs({...}) do _includeMixin(self, mixin) end
            return self
        end
    }
}

function middleclass.class(name, super)
    assert(type(name) == 'string', "A name (string) is needed for the new class")
    return super and super:subclass(name) or _includeMixin(_createClass(name), DefaultMixin)
end

setmetatable(middleclass, { __call = function(_, ...) return middleclass.class(...) end })

return middleclass
