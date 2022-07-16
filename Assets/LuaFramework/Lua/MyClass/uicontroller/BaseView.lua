--UI面板的基类：
BaseView = BaseView or BaseClass()

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
function BaseView:__init(view_name)
    self.is_open = false                                     --是否打开
    self.view_name = view_name                               --模块面板名字
    self.root_node = nil                                     --当前节点
    self.root_node_transform =  nil                          --当前节点位置
    self.canvas = nil                                        --当前Canvas
    self.node_list = {}                                      --node_list子节点列表
    self.view_layer = UiLayer.Normal                         --模块层级
    self.view_render = BaseViewRender.New()                  --模块对象类
    self.view_loader = BaseViewLoader.New()                  --资源加载类
    self.is_view_loade = false							     -- 是否已加载(index = 0)
    --#注册面板信息
    UIManager.Instance:RegisterView(self.view_name,self)
end


function BaseView:__delete()
    UIManager.Instance:UnRegisterView(self.view_name)
    if self.view_render then
        self.view_render:DeleteMe()
        self.view_render = nil
    end

    if self.view_loader then
        self.view_loader:DeleteMe()
        self.view_loader = nil
    end
end


function BaseView:Release()


end

--打开面板：
function BaseView:Open(index)
    local show_index = index
    if nil == show_index then
        --计算红点打开的索引值：
    end
    if self:IsOpen() then
        --只执行刷新页面的操作：
        return
    end
    --执行创建和刷新面板的操作：
    self.is_open = true
    --索引值递增：
    def_view_name_index = def_view_name_index + 1
    --模块视图名赋值：
    self.view_name = IsNullOrEmpty(self.view_name) and "BaseView"..def_view_name_index or self.view_name
    self.view_render:SetViewName(self.view_name)
    --获取节点信息
    local root_node,root_canvas,gameobj_root_transform,node_list = self.view_render:TryCreateRooNode()
    self.canvas = root_canvas
    self.root_node = root_node
    self.root_node_transform = gameobj_root_transform
    LogTable(node_list)
    self.node_list = node_list
    self.view_loader:SetGameObjRootTransform(gameobj_root_transform)
    self:OpenCallBack()
    self:ChangeToIndex(show_index)
    --添加到试图管理器
    UIManager.Instance:AddOpenView(self)
end

--切换面板索引
function BaseView:ChangeToIndex(index)
    if nil == index then
        print_log("[[BaseView] ChangeToIndex error!,请指定index")
    end
    if not self:IsOpen() then
        print_log(self.view_name,"-->面板没打开")
        return
    end
    if self.show_index == index then
        --刷新面板信息：
        self:__TryFlushInex(index)
        return
    end
    --新打开的面板索引
    self.show_index =index
    if self.view_loader:IsLoadedIndex(index) then
        self:__RefreshIndex(index)
    else
        --每个不是0的index都是先加载0
        local index_list = nil
        if 0 ~= index and not self.view_loader:IsLoadedIndex(0) then
            index_list = {0,index}
        else
            index_list = {index}
        end
        for _,v in ipairs(index_list) do
            self:__LoadIndex(v)
        end
    end
end

--索引加载：
function BaseView:__LoadIndex(index)
    self.view_loader:Load(index,function(index,gamobjs)
        self.is_view_loaded = true
        self.view_render:AddRenderGameObjs(index, gamobjs)
        if 0 == index then
            self:LoadCallBack()
        end
        self:LoadIndexCallBack(index)
    end)
end



function BaseView:Flush()
    self:OnFlush()
end

--尝试刷新索引：
function BaseView:__RefreshIndex(index)

end

--尝试刷新索引：
function BaseView:__TryFlushInex(index)

end

--添加加载的ui面板预制体
function BaseView:AddViewResource(index, bundle_name, asset_name)
    self.view_loader:AddViewResource(index, bundle_name, asset_name)
end

--是否打开：
function BaseView:IsOpen()
    return self.is_open
end

--获取当前模块属于哪个层级
function BaseView:GetLayer()
    return self.view_layer
end

-------【生命周期(star)】------

function BaseView:OpenCallBack()

end

function BaseView:LoadIndexCallBack()
--切换时索引时调用
end

function BaseView:LoadCallBack()
--索引为0的时候调用（默认显示）
end

function BaseView:OnFlush()

end

function BaseView:CloseCallBack()

end

function BaseView:ReleaseCallBack()

end

--------【生命周期(end)】---------
