--base.lua代码
--保存类类型的虚表
local _class = {}
function BaseClass(super)
    -- ⽣成⼀个类类型
    local class_type = {}
    -- 在创建对象的时候⾃动调⽤
    class_type.__init = false
    class_type.__delete = false
    class_type.super = super
    class_type.New = function(...)
        -- ⽣成⼀个类对象
        local obj = {_class_type = class_type}
        -- 在初始化之前注册基类⽅法
        setmetatable(obj, { __index = _class[class_type] })
        -- 调⽤初始化⽅法
        do
            local create
            create = function(c, ...)
                if c.super then
                    create(c.super, ...)
                end
                if c.__init then
                    c.__init(obj, ...)
                end
            end
            create(class_type, ...)
        end

        --注册一个Delete方法
        obj.DeleteMe = function(self)
            local now_super = self._class_type
            while now_super ~= nil do
                if now_super.__delete then
                    now_super.__delete(self)
                end
                now_super = now_super.super
            end
        end

        return obj
    end
    local vtbl = {}
    _class[class_type] = vtbl
    setmetatable(class_type, {__newindex = function(t,k,v) vtbl[k] = v end, __index = vtbl})
    if super then
        setmetatable(vtbl, {__index = function(t,k) return _class[super][k] end})
    end
    return class_type
end


