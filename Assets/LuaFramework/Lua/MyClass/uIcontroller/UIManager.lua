local UIManager = class("UIManager")



function UIManager:__init()
    --面板全局查找节点：
    self.root_parent = find("GameManager/UICanvas")
    --模块UI预制体
    self.ui_obj_prefab = find("GameManager/BaseView")

    --存取所有游戏内视图的View数据(在游戏一运行时就开始注册)
    self.view_list = {}

    --存取当前的模块面板信息：
    self.panel_list_tab = {}

end


function UIManager:__delete()
    print_log("UIManager:__delete()")
    self.root_parent = nil
    self.ui_obj_prefab = nil
    self.view_list = nil
    self.panel_list_tab = nil
end


--获得面板UI节点
function UIManager:GetRootParent()
    return self.root_parent
end


--获得节点通用预制体
function UIManager:GetUIObjPrefab()
    return self.ui_obj_prefab
end







--创建面板：
function UIManager:Open(view_name, tab_index)
    if self.view_list[view_name] == nil then
        --第一次生成面板时：

    end
end




--加载面板数据：【避免多次创建{}】
function UIManager:LoadPanel(list_panel,layoutType)
    --面板数据为空，直接返回：
    if nil == list_panel then return end
    local cur_Panel_tab = {}
    local data_Panel_tab = {}
    --对已经加载对面板进行存取：
    for view_module_name,view_alldata in pairs(list_panel) do
        --如果存在面板数据：
        if view_alldata then
            for i = 1 , #view_alldata do
                data_Panel_tab[i].name = view_alldata[i].name
                data_Panel_tab[i].obj = MgrCenter.GetManager(ManagerNames.BaseViewLoader):LoadAsset("")
                --//后加//
            end
        end
        cur_Panel_tab.view_module_name  = view_module_name         --模块名称
        cur_Panel_tab.data_panel = data_Panel_tab                  --模块下所有UI面板信息
        cur_Panel_tab.layoutType = layoutType                      --模块属于哪个层级
    end
    self:__AddPanelTotable(cur_Panel_tab)
end

--添加模块面板数据到表
function UIManager:__AddPanelTotable(new_tab)
    return table.insert(self.panel_list_tab,new_tab)
end

--移除表里指定[模块名字]的模块面板数据
function UIManager:__RemovePanelInTableByViewModuleName(view_module_name)
    if nil == self.panel_list_tab then
        print_error("当前模块面板数据Table为空")
        return nil
    end
    return table.removeKey(self.panel_list_tab, view_module_name)
end

--清空表里的模块面板数据
function UIManager:__ClearPanelIntable(new_tab)
    self.panel_list_tab = nil
end

--获得当前表里的模块面板信息：
function UIManager:GetViewPanelDataByViewModuleName(view_module_name)
    if nil == self.panel_list_tab then
        print_error("当前模块面板数据Table为空")
        return nil
    end
    --遍历取值：
    for k,v in pairs(self.panel_list_tab) do
        if k == view_module_name then
            return v
        end
    end
    print_error(string.format("当前模块名为：%s 的面板数据为空",view_module_name))
    return nil
end

--获得所有模块视图数据
function UIManager:GetAllViewPanelData()
    if nil == self.panel_list_tab then
        print_error("当前模块面板数据Table为空")
        return nil
    end
    return self.panel_list_tab
end

----------------------------




--创建面板：
function UIManager:__CreatePanel(abName,panelname,layoutType)
   -- if IsDevelopModel then
        --拿本地素材

    --else
        --拿ab包素材
        local abName = panelname.ToLower() + AppConst.ExtName;
        local res_mgr = MgrCenter:GetManager(ManagerNames.Resource)
        res_mgr:LoadAsset(panelname,abName,function(obj)
            print_log("对象创建成功",obj)
        end)
    --end
end


--对面板层级进行排序
function UIManager:CreatePanel(obj)
    --local abName = panelName.ToLower() + AppConst.ExtName;
    ----创建面板
    --self:CreatePanel(abName,panelName,layoutType)
end



--创建不同的层级：
function UIManager:CreateLayer(name, layerType)
    local layerName = name..'_Layer'
    local layerObj = GameObject.New(layerName)
    layerObj.layer = LayerMask.NameToLayer("UI")
    layerObj.transform:SetParent(uiCanvas.transform)
    layerObj.transform.localScale = Vector3.one

    local rectType = typeof(RectTransform)
    local rect = layerObj:AddComponent(rectType)
    rect.anchorMin = Vector2.zero
    rect.anchorMax = Vector2.one
    rect.sizeDelta = Vector2.zero
    rect.anchoredPosition3D = Vector3.zero
    rect:SetSiblingIndex(layerType)
    self.mLayers[layerType] = layerObj
end

--活动的当前层级对象：
function UIManager:GetLayer(layerType)
    return self.mLayers[layerType]
end




return UIManager