UIManager = UIManager or BaseClass()

function UIManager:__init()
    UIManager.Instance = self
    --面板全局查找节点：
    self.root_parent = find("GameManager/UICanvas")

    --模块UI预制体
    self.ui_obj_prefab = find("GameManager/BaseView")

    --存取所有已打开的视图面板
    self.open_view_list = {}

    --存取当前的模块面板信息：
    self.view_list = {}

end

function UIManager:__delete()
    print_log("UIManager:__delete()")
    self.root_parent = nil
    self.ui_obj_prefab = nil
    self.open_panel_list = nil
    self.view_list = nil
    UIManager.Instance = nil
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
    if self.open_panel_list[view_name] == nil then
        --第一次生成面板时：

    else

    end
end


--添加模块面板数据到表
function UIManager:RegisterView(view_name,view)
    if IsNullOrEmpty(view_name) then
        print_error("[ViewManager] 请指定view_name!")
    end
    self.view_list[view_name] = view
end

--移除表里指定[模块名字]的模块面板数据
function UIManager:UnRegisterView(view_name)
    if nil == self.view_list then
        print_error("当前模块面板数据Table为空")
        return nil
    end
    return table.removeKey(self.view_list, view_name)
end

--清空表里的模块面板数据
function UIManager:ClearListView()
    self.view_list = nil
end

--获得当前表里的模块面板信息：
function UIManager:GetViewPanelDataByViewModuleName(view_name)
    if nil == self.view_list then
        print_error("当前模块面板数据Table为空")
        return nil
    end
    --遍历取值：
    for k,v in pairs(self.view_list) do
        if k == view_name then
            return v
        end
    end
    print_error(string.format("当前模块名为：%s 的面板数据为空",view_name))
    return nil
end

--获得所有模块视图数据
function UIManager:GetAllViewPanelData()
    if nil == self.view_list then
        print_error("当前模块面板数据Table为空")
        return nil
    end
    return self.view_list
end

--添加视图数据
function UIManager:AddOpenView(view)
    self:RemoveOpenView(view,true)
    self.open_view_list[view:GetLayer()] = self.open_view_list[view:GetLayer()] or {}
    table.insert(self.open_view_list[view:GetLayer()],view)
end

--移除视图数据
function UIManager:RemoveOpenView(view,ignore)
    if nil == self.open_view_list[view:GetLayer()] then
        return
    end
    for k,v in ipairs(self.open_view_list[view:GetLayer()]) do
        if v == view then
            table.remove(self.open_view_list[view:GetLayer()],k)
        end
    end
    if not ignore then

    end
end

--打开面板：
function UIManager:Open(view_name,tab_index,key,values)
    local now_view = self.view_list[view_name]
    if nil ~= now_view then
        if tonumber(tab_index) ==  nil and type(tab_index) == 'string' then
            --index = TabIndex[tab_index]
        else
            index = tonumber(tab_index)
        end


    end
end


return UIManager