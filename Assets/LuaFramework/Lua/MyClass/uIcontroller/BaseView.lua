--UI面板的基类：
BaseView = class("BaseView")


UiLayer = {
    SceneName = 0,				-- 场景名字
    FloatText = 1,				-- 飘字
    MainUILow = 2,				-- 主界面(低)
    MainUI = 3,					-- 主界面
    MainUIHigh = 4,				-- 主界面(高)
    Normal = 5,					-- 普通界面
    Pop = 6,					-- 弹出框
    PopWhite = 7,				-- 透明弹出框
    PopTop = 8,					-- 弹出框(高)
    Guide = 9,					-- 引导层
    SceneLoading = 10,			-- 场景加载层
    SceneLoadingPop = 11,		-- 场景加载层上的弹出层
    Disconnect = 12,			-- 断线面板弹出层
    Standby = 13,				-- 待机遮罩
    MaxLayer = 14
}



local def_view_name_index = 0                                --默认面板的索引值
function BaseView:initialize(view_name)
    self.is_open = false                                     --是否打开
    self.view_name = view_name                               --模块面板名字

    self.view_loader = BaseViewRender:new()                  --模块对象类
end

--加载面板预制体：
function BaseView:Load(prefab_name)
    self:OpenCallBack()
    panelMgr:CreatePanel(prefab_name, self.OnCreate);
end


--打开面板：
function BaseView:Open(index)
    local show_index = index
    if nil == show_index then
        --计算红点打开的索引值：
    end
    if self:IsOpen() then
        --只执行刷新页面的操作：
    else
        --执行创建和刷新面板的操作：
        self.is_open = true
        --索引值递增：
        def_view_name_index = def_view_name_index + 1
        --模块视图名赋值：
        self.view_name = IsNullOrEmpty(self.view_name) and "BaseView"..def_view_name_index or self.view_name
        self.view_loader:SetViewName(self.view_name)

    end

end


--是否打开：
function BaseView:IsOpen()
    return self.is_open
end

-------【生命周期(star)】------

function BaseView:OpenCallBack()

end

function BaseView:LoadCallBack()

end

function BaseView:FlushView()

end

function BaseView:CloseCallBack()

end

function BaseView:ReleaseCallBack()

end

--------【生命周期(end)】---------
