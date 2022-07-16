-- UI面板加载并存取类：
BaseViewLoader = BaseViewLoader or BaseClass()

function BaseViewLoader:__init()
    self.list_panel = {}
    self.source_obj_order_list = {}
    self.gameobj_root_transform = nil

    self.is_index_loading = false           --是否加载资源中
    self.is_index_loaded_t = {}             --资源加载情况列表
    self.wait_load_index_queue = {}         --预加载队列
    self.wait_load_asset_index_queue = {}   --等待资源加载的队列列表

end

function BaseViewLoader:__delete()

    if self.list_panel then
        for _, list in pairs(self.list_panel) do
            for i,v in ipairs(list) do
                v.obj = nil
            end
        end
        self.list_panel = nil
    end

    self.wait_load_index_queue ={}
    self.source_obj_order_list = {}
    self.gameobj_root_transform = nil
    self.is_index_loaded_t = {}
    self.wait_load_asset_index_queue = {}
end

--添加各个模块的ab面板预制体
function BaseViewLoader:AddViewResource(index, bundle_name, asset_name, safe_area_mode)
    if nil == index then
        print_error("[BaseViewLoader]AddViewResource 请指定index不要为nil")
        return
    end
    local reource_list = self.list_panel[index]
    if nil == reource_list then
        reource_list = {}
        self.list_panel[index] = reource_list
    end
    -- 防止在一个index下重复添加
    for k,v in ipairs(reource_list) do
        if v.bundle_name == bundle_name and v.asset_name == asset_name then
            return
        end
    end
    local resource_obj = {}
    resource_obj.bundle_name = bundle_name
    resource_obj.asset_name = asset_name
    resource_obj.obj =  nil
    resource_obj.transform_cfg = nil
    resource_obj.safe_area_mode = safe_area_mode
    table.insert(reource_list, resource_obj)
    table.insert(self.source_obj_order_list, resource_obj)
end

--通过ab路径和名字获取Obj
function BaseViewLoader:GetViewResourceGameObj(bundle_name, asset_name)
    for k,v in pairs(self.source_obj_order_list) do
        if v.bundle_name == bundle_name and v.asset_name == asset_name then
            return v.obj
        end
    end
    return nil
end

--设置根节点
function BaseViewLoader:SetGameObjRootTransform(gameobj_root_transform)
    self.gameobj_root_transform = gameobj_root_transform
end

-- 根据请求加载index的顺序，需要按预期顺序加载完成，否则逻辑层可能会不可控
function BaseViewLoader:Load(index, load_callback)
    if not self.is_index_loading and #self.wait_load_index_queue <= 0 then
        self:__DoLoad(index, load_callback)
        return
    end
    --避免重复：
    for i,v in ipairs(self.wait_load_index_queue) do
        if v.index == index then
            return
        end
    end
    --存取待加载列表：
    table.insert(self.wait_load_index_queue, {index = index, load_callback = load_callback})
end

--资源加载：
function BaseViewLoader:__DoLoad(index, load_callback)
    if self.is_index_loading then
        print_error("[BaseViewLoader] __DoLoad正在执行，请检查代码", index)
        return
    end
    self.is_index_loading = true
    --是否已经加载过了：
    if self:IsLoadedIndex(index) then
        self:__OnLoadComplete(index, load_callback)
        return
    end
    local resource_list = self:GetResourceListByIndex(index)
    if #resource_list <=0 then
        self:__OnLoadComplete(index,load_callback)
        return
    end
    local load_count = #resource_list
    --资源加载器：
    local resMgr = ObjPoolManager.Instance
    for _,resources_obj in pairs(resource_list) do
        local bundle_name,asset_name = resources_obj.bundle_name,resources_obj.asset_name
        resMgr:CreateObj(bundle_name, asset_name, function(rend)
            load_count = load_count - 1
            if rend ~= nil and rend:GetView() then
                resources_obj.obj = rend:GetView()
                rend:SetName(asset_name)
                rend:SetParent(self.gameobj_root_transform,false)
            end
            if load_count <=0 then
                self.is_index_loading = false
                self:UpdateOrder()--根据传入顺序排序
                self:__OnLoadComplete(index,load_callback)
            end
        end)
    end
end

--通过索引获取预制体的对象
function BaseViewLoader:GetResourceListByIndex(index)
    if nil ~= self.list_panel[index] then
        return self.list_panel[index]
    end
    return self.list_panel[0] or {}
end

-- 排序（根据Add传入顺序排序）
function BaseViewLoader:UpdateOrder()
    if #self.source_obj_order_list > 1 then
        for i,v in ipairs(self.source_obj_order_list) do
            if not IsNil(v.gameobj) then
                v.gameobj.transform:SetAsLastSibling()
            end
        end
    end
end

--更新刘海区域信息
function BaseViewLoader:UpdateSafeArea(gameobj, safe_area_mode)
    --if nil == safe_area_mode or SafeAreaMode.None == safe_area_mode then
    --    return
    --end
    --if nil == self.time_request then
    --    self.time_request = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.Update, self), 1)
    --end
    --
    --table.insert(self.check_safe_area_list, {gameobj = gameobj, safe_area_mode = safe_area_mode})
    --self:CheckSafeArea(gameobj, safe_area_mode)
end


--更新到到父节点下
function BaseViewLoader:UpdateTransform(gameobj, transform_cfg)
    if nil == transform_cfg then
        return
    end

    local rect = gameobj.transform:GetComponent(typeof(UnityEngine.RectTransform))
    if rect then
        if transform_cfg.vector2 then
            rect.anchoredPosition = transform_cfg.vector2
        end

        if transform_cfg.sizeDelta then
            rect.sizeDelta = transform_cfg.sizeDelta
        end
    end
end

--通过索引值获得Add的AssetsName和PanelName
--(有些并没有为index配置任何资源，而是仅配了0。但是在在使用上却传index）
function GetResourceListByIndex(index)
    if nil ~= self.list_panel[index] then
        return self.list_panel[index]
    end
    return self.list_panel[0] or {}
end


--加载完成后执行的操作
function BaseViewLoader:__OnLoadComplete(index, load_callback)
    self.is_index_loaded_t[index] = true
    self.is_index_loading = false
    load_callback(index,self:GetLoadedIndexGameObjList(index))
    --判断是否继续加载下个资源
    if #self.wait_load_index_queue > 0 then
        --永远移除第一个
        local load_t = table.remove(self.wait_load_index_queue,1)
        --加载下个资源
        self:__DoLoad(load_t.index,load_t.load_callback)
    end
end

-- 所有index下都要走load流程，不管index下有没有进行配置资源，以确保回调执行稳定一致
function BaseViewLoader:IsLoadedIndex(index)
    return nil ~= self.is_index_loaded_t[index]
end


--
function BaseViewLoader:GetLoadedIndexGameObjList(index)
    if not self:IsLoadedIndex(index)then
        print_error("BaseViewLoader] GetLoadedIndexGameObjList, index未加载完成",index)
        return {}
    end
    local gameobj_list = {}
    local resources_list = self:GetResourceListByIndex(index)
    for k,v in ipairs(resources_list) do
        if not IsNil(v.obj) then
            table.insert(gameobj_list,v.obj)
        else
            print_error("[BaseViewLoader] GetLoadedIndexGameObjList 严重错误, gameobj is nil", index)
        end
    end
    return gameobj_list
end