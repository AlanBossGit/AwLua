---@class BaseViewLoader
BaseViewLoader = BaseViewLoader or BaseClass()

function BaseViewLoader:__init()
    self.reource_t = {}
    self.source_obj_order_list = {}
    self.gameobj_root_transform = nil
    self.is_async_load = true
    self.load_priority = ResLoadPriority.high   -- A
    self.is_use_objpool = false

    self.wait_load_index_queue = {}
    self.is_index_loading = false

    self.wait_load_asset_index_queue = {}
    self.is_load_asset_index_loading = false

    self.is_index_loaded_t = {}

    self.check_safe_area_list = {}
end

function BaseViewLoader:__delete()
    if self.time_request then
        GlobalTimerQuest:CancelQuest(self.time_request)         --A
        self.time_request = nil
    end
end

function BaseViewLoader:Clear()
    if self.time_request then
        GlobalTimerQuest:CancelQuest(self.time_request)         --A
        self.time_request = nil
    end

    if self.__gameobj_loaders then
        ReleaseGameobjLoaders(self)                             --A
    end

    if self.__res_loaders then
        ReleaseResLoaders(self)                                 --A
    end

    for _, list in pairs(self.reource_t) do
        for i,v in ipairs(list) do
            v.gameobj = nil
        end
    end

    self.gameobj_root_transform = nil
    self.wait_load_index_queue = {}
    self.is_index_loading = false
    self.wait_load_asset_index_queue = {}
    self.is_load_asset_index_loading = false
    self.is_index_loaded_t = {}
    self.check_safe_area_list = {}
end

function BaseViewLoader:AddViewResource(index, bundle_name, asset_name, transform_cfg, safe_area_mode)
    if nil == index then
        print_error("[BaseViewLoader]AddViewResource 请指定index不要为nil")
        return
    end

    local reource_list = self.reource_t[index]
    if nil == reource_list then
        reource_list = {}
        self.reource_t[index] = reource_list
    end

    -- 防止在一个index下重复添加
    for i,v in ipairs(reource_list) do
        if v.bundle_name == bundle_name and v.asset_name == asset_name then
            return
        end
    end

    local resource_obj = {}
    resource_obj.bundle_name = bundle_name
    resource_obj.asset_name = asset_name
    resource_obj.gameobj = nil
    resource_obj.transform_cfg = transform_cfg
    resource_obj.safe_area_mode = safe_area_mode
    table.insert(reource_list, resource_obj)
    table.insert(self.source_obj_order_list, resource_obj)
end

function BaseViewLoader:GetViewResourceGameObj(bundle_name, asset_name)
    for k,v in pairs(self.source_obj_order_list) do
        if v.bundle_name == bundle_name and v.asset_name == asset_name then
            return v.gameobj
        end
    end

    return nil
end

function BaseViewLoader:SetGameObjRootTransform(gameobj_root_transform)
    self.gameobj_root_transform = gameobj_root_transform
end

function BaseViewLoader:SetIsAsyncLoad(is_async_load)
    self.is_async_load = is_async_load
end

function BaseViewLoader:SetLoadPriority(load_priority)
    self.load_priority = load_priority
end

function BaseViewLoader:SetIsUseObjPool(is_use_objpool)
    self.is_use_objpool = is_use_objpool
end

-- 有些并没有为index配置任何资源，而是仅配了0。但是在在使用上却传index
function BaseViewLoader:GetResourceListByIndex(index)
    if nil ~= self.reource_t[index] then
        return self.reource_t[index]
    end

    return self.reource_t[0] or {}
end

-- 所有index下都要走load流程，不管index下有没有进行配置资源，以确保回调执行稳定一致
function BaseViewLoader:IsLoadedIndex(index)
    return nil ~= self.is_index_loaded_t[index]
end

function BaseViewLoader:GetLoadedIndexGameObjList(index)
    if not self:IsLoadedIndex(index) then
        print_error("[BaseViewLoader] GetLoadedIndexGameObjList, index未加载完成", index)
        return {}
    end

    local gameobj_list = {}
    local reource_list = self:GetResourceListByIndex(index)

    for i,v in ipairs(reource_list) do
        if not IsNil(v.gameobj) then
            table.insert(gameobj_list, v.gameobj)
        else
            print_error("[BaseViewLoader] GetLoadedIndexGameObjList 严重错误, gameobj is nil", index)
        end
    end

    return gameobj_list
end

-- 预加载资源
function BaseViewLoader:LoadAssets(index_list, load_callback)
    for _,v in ipairs(index_list) do
        table.insert(self.wait_load_asset_index_queue, v)
    end

    if not self.is_load_asset_index_loading then
        self:__DoLoadNextAsset(load_callback)
        return
    end
end

function BaseViewLoader:__DoLoadNextAsset(load_callback)
    if self.is_load_asset_index_loading then
        self.is_load_asset_index_loading = false
        print_error("[BaseViewLoader] __DoLoadAsset正在执行，请检查代码")
        return
    end

    if #self.wait_load_asset_index_queue <= 0 then
        self.is_load_asset_index_loading = false
        load_callback()
        return
    end

    self.is_load_asset_index_loading = true
    local index = table.remove(self.wait_load_asset_index_queue, 1)
    if self:IsLoadedIndex(index) then
        self.is_load_asset_index_loading = false
        self:__DoLoadNextAsset(load_callback)
        return
    end

    local resource_list = self:GetResourceListByIndex(index)
    local load_count = #resource_list
    if load_count <= 0 then
        self.is_load_asset_index_loading = false
        self:__DoLoadNextAsset(load_callback)
        return
    end

    for _, resource_obj in ipairs(resource_list) do
        local bundle_name, asset_name = resource_obj.bundle_name, resource_obj.asset_name
        local loader_key = bundle_name .. " " .. asset_name
        local async_loader = AllocResAsyncLoader(self, loader_key)
        async_loader:SetIsASyncLoad(self.is_async_load)
        if self.is_async_load then
            async_loader:SetLoadPriority(self.load_priority)
        end

        async_loader:Load(bundle_name, asset_name, TypeUnityPrefab, function()
            load_count = load_count - 1
            if load_count <= 0 then
                self.is_load_asset_index_loading = false
                self:__DoLoadNextAsset(load_callback)
            end
        end)
    end
end

-- 根据请求加载index的顺序，需要按预期顺序加载完成，否则逻辑层可能会不可控
function BaseViewLoader:Load(index, load_callback)
    if not self.is_index_loading and #self.wait_load_index_queue <= 0 then
        self:__DoLoad(index, load_callback)
        return
    end

    for i,v in ipairs(self.wait_load_index_queue) do
        if v.index == index then
            return
        end
    end

    table.insert(self.wait_load_index_queue, {index = index, load_callback = load_callback})
end

function BaseViewLoader:__DoLoad(index, load_callback)
    if self.is_index_loading then
        print_error("[BaseViewLoader] __DoLoad正在执行，请检查代码", index)
        return
    end

    self.is_index_loading = true

    if self:IsLoadedIndex(index) then
        self:__OnLoadComplete(index, load_callback)
        return
    end

    local resource_list = self:GetResourceListByIndex(index)
    if #resource_list <= 0 then
        self:__OnLoadComplete(index, load_callback)
        return
    end

    local load_count = #resource_list
    for _, resource_obj in ipairs(resource_list) do
        local bundle_name, asset_name = resource_obj.bundle_name, resource_obj.asset_name
        local loader_key = bundle_name .. " " .. asset_name
        local async_loader = AllocAsyncLoader(self, loader_key)
        async_loader:SetIsASyncLoad(self.is_async_load)
        if self.is_async_load then
            async_loader:SetLoadPriority(self.load_priority)
        end
        async_loader:SetIsUseObjPool(self.is_use_objpool)
        async_loader:SetParent(self.gameobj_root_transform)

        async_loader:Load(bundle_name, asset_name, function(gameobj)
            load_count = load_count - 1
            if not IsNil(gameobj) then
                gameobj.name = asset_name
            end

            resource_obj.gameobj = gameobj
            self:UpdateTransform(gameobj, resource_obj.transform_cfg)
            self:UpdateSafeArea(gameobj, resource_obj.safe_area_mode)

            if load_count <= 0 then
                self.is_index_loading = false
                self:UpdateOrder()
                self:__OnLoadComplete(index, load_callback)
            end
        end)
    end
end

function BaseViewLoader:__OnLoadComplete(index, load_callback)
    self.is_index_loaded_t[index] = true
    self.is_index_loading = false
    load_callback(index, self:GetLoadedIndexGameObjList(index))
    if #self.wait_load_index_queue > 0 then
        local load_t = table.remove(self.wait_load_index_queue, 1)
        self:__DoLoad(load_t.index, load_t.load_callback)
    end
end

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

-- 排序
function BaseViewLoader:UpdateOrder()
    if #self.source_obj_order_list > 1 then
        for i,v in ipairs(self.source_obj_order_list) do
            if not IsNil(v.gameobj) then
                v.gameobj.transform:SetAsLastSibling()
            end
        end
    end
end

local zero_offset = Vector2(0, 0)
function BaseViewLoader:CheckSafeArea(gameobj, safe_area_mode)
    local rect = gameobj.transform:GetComponent(typeof(UnityEngine.RectTransform))
    if rect then
        local mode, offset = SafeBaseView.GetSafeAreaMode()
        if mode ~= SafeAreaMode.None and (safe_area_mode == SafeAreaMode.Both or mode == safe_area_mode) then
            if mode == SafeAreaMode.Left then
                rect.offsetMin = offset
                rect.offsetMax = zero_offset
            else
                rect.offsetMax = offset
                rect.offsetMin = zero_offset
            end
        else
            rect.offsetMax = zero_offset
            rect.offsetMin = zero_offset
        end
    end
end

function BaseViewLoader:UpdateSafeArea(gameobj, safe_area_mode)
    if nil == safe_area_mode or SafeAreaMode.None == safe_area_mode then
        return
    end

    if nil == self.time_request then
        self.time_request = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.Update, self), 1)
    end

    table.insert(self.check_safe_area_list, {gameobj = gameobj, safe_area_mode = safe_area_mode})
    self:CheckSafeArea(gameobj, safe_area_mode)
end

function BaseViewLoader:Update()
    for k,v in pairs(self.check_safe_area_list) do
        self:CheckSafeArea(v.gameobj, v.safe_area_mode)
    end
end