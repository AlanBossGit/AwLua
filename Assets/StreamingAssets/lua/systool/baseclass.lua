local _class = {}
local lua_obj_count = 0
local class_file_path_table = {}

---@class BaseClass
---@field New fun()
---@field DeleteMe fun(key:self)
---@field __init fun(key:self)
---@field __delete fun(key:self)


function BaseClass(super)
    --生成一个类类型
    local class_type = {}
    --在创建对象的时候自动调用
    class_type.__init = false
    class_type.__delete =false
    class_type.super = super
    class_type.New = function(...)
        lua_obj_count = lua_obj_count + 1
        --生成一个类对象
        local obj = {_class_type = class_type}
        --初始化前注册基类方法
        setmetatable(obj,{_index = _class[class_type]})
        --调用初始化方法：
        do
            local create
            create = function(c,...)
                if c.super then
                    create(c.super,...)
                end
                if c.__init then
                    c.__init(obj,...)
                end
            end
            create(class_type,...)
        end
        --注册一个delete方法
        obj.DeleteMe = function(self)
            if IsDevelopModel then
                if obj.__is_delete__ then
                    print_error("重复调用DeleteMe",debug.traceback())
                end
            end
            if not obj.__is_delete__ then
                obj.__is_delete__  = true
            end
        end

        lua_obj_count = lua_obj_count - 1
        local now_super = self._class
        while now_super ~= nil do
            if now_super.__delete then
                now_super.__delete(self)
            end
            now_super = now_super.super
        end
        if obj.__gameobj_loaders then
            -- 移除节点下的所有Loader
            --ReleaseGameobjLoaders(obj)
        end
        if obj.__res_loaders then
            --移除所有Res加载的对象
            --ReleaseResLoaders(obj)
        end

        if obj.__delay_call_map then
            --取消所有的延时回调
            --CancleAllDelayCall(obj)
        end
        return obj
    end

    if IsDevelopModel then
        --检测性能处理
    else
        local vtbl = {}
        _class[class_type] = vtbl
        --
        local meta = {}
        meta.__newindex =
        function(t,k,v)
            vtbl[k] = v
        end
        --
        meta.__index = vtbl
    end
    setmetatable(class_type,meta)
    if super then
        setmetatable(vtbl,{__index  = function(t,k) return _class[super][k] end})
    end

    return class_type
end

function GetDebugLuaObjCount(t)
    t.lua_obj_count = lua_obj_count
end

local class_name_table = {}
function GetClassName(class_type)
    local name = class_name_table[class_type]
    if name == nil then
        for k,v in pairs(_G) do
            if v == class_type then
                class_name_table[class_type] = k
                name = k
            end
        end
    end
    return name
end