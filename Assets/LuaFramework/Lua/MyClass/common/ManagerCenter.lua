 ManagerCenter = ManagerCenter or BaseClass()

function ManagerCenter:__init()
    ManagerCenter.Instance = self
    self.managers = {}
    --C# Manager--
    --着色器管理器
    self:AddManager(CS_ManagerNames.Shader, self:GetCSharpManager("ShaderManager"))
    --资源加载管理器
    self:AddManager(CS_ManagerNames.Resource, self:GetCSharpManager("ResourceManager"))

    --C# Ext Manager--
    --self:AddManager(ManagerNames.Timer, self:GetExtManager("TimerManager"))
    --self:AddManager(ManagerNames.Config, self:GetExtManager("ConfigManager"))

    --Lua Manager--

    --添加处理UI的控制器的管理器
    --self:AddManager(ManagerNames.Ctrl, require("Logic/CtrlManager"), true)
    --控制视图面板加载和销毁的数据管理器
    --self:AddManager(ManagerNames.BaseViewLoader,require("MyClass/uicontroller/BaseViewLoader"),true)
    --控制视图面板开关的管理器：
    --self:AddManager(ManagerNames.UIManager,require("MyClass/uicontroller/UIManager"),true)
    --    --self:AddManager(ManagerNames.Adapter, require "Manager.AdapterManager", true)
    --    --self:AddManager(ManagerNames.Map, require "Manager.MapManager", true)
    --    --self:AddManager(ManagerNames.Level, require "Manager.LevelManager", true)
    --    --self:AddManager(ManagerNames.Network, require "Manager.NetworkManager", true)
    --    --self:AddManager(ManagerNames.Table, require "Data.TableManager", true)
    --    --self:AddManager(ManagerNames.UI, require "Manager.UIManager", true)
    --    --self:AddManager(ManagerNames.Panel, require "Manager.PanelManager", true)
    --    --self:AddManager(ManagerNames.Component, require "Manager.ComponentManager", true)
    --    --self:AddManager(ManagerNames.Module, require "Manager.ModuleManager", true)
    --    --self:AddManager(ManagerNames.Handler, require "Manager.HandlerManager", true)
    --    --self:AddManager(ManagerNames.RedDot, require "Manager.RedDotManager", true)
    --    --self:AddManager(ManagerNames.Event, require "Manager.EventManager")

    logWarn('ManagerCenter:InitializeOK...')
end
function ManagerCenter:__delete()
    --销毁所有来自Lua管理器的注册
    for k,v in pairs(ManagerNames) do
        self:RemoveManager(v)
    end

    for k,v in pairs(CS_ManagerNames) do
        self:RemoveManager(v)
    end

    ManagerCenter.Instance  = nil
end

function ManagerCenter:AddManager(name, manager, needInit)
    if name == nil or manager == nil then
        logError('ManagerCenter:AddManager Error!! '..name..' was nil.')
        return
    end
    self.managers[name] = manager
    needInit = needInit or nil
    if needInit == true then
        manager:Initialize()
    end
end

function ManagerCenter:GetManager(name)
    return self.managers[name]
end

function ManagerCenter:RemoveManager(name,is_need_delete)
    return table.removeKey(self.managers, name)
end

function ManagerCenter:GetCSharpManager(name)
    return ManagementCenter.GetManager(name)
end

function ManagerCenter:GetExtManager(name)
    return ManagementCenter.GetExtManager(name)
end
