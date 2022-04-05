ViewManager = ViewManager or BaseClass()

function ViewManager:__init()
    if nil ~= ViewManager.Instance then
        print_error("[ViewManager]:Attempt to create singleton twice!")
    end
    ViewManager.Instance = self

    self.view_list = {}

    self.open_view_list = {}
    self.ui_role_model_view_list = {}

    self.wait_load_chat_list = {}

end

function ViewManager:__delete()
    if self.scene_all_load_complete_event then
        GlobalEventSystem:UnBind(self.scene_all_load_complete_event)
        self.scene_all_load_complete_event = nil
    end

    ViewManager.Instance = nil
end

function ViewManager:DestoryAllAndClear(record_list)
    for k,v in pairs(BaseView.open_view_list or {}) do
        v:Close()
        v:Release()
    end

    BaseView.open_view_list = {}

    for k,v in pairs(self.view_list) do
        if v:IsOpen() then
            v:Close()
            v:Release()
        end
    end

    self.view_list = {}
    self.open_view_list = {}
    self.ui_role_model_view_list = {}
    self.wait_load_chat_list = {}
end

-- 注册一个界面
function ViewManager:RegisterView(view, view_name)
    if nil == view_name or "" == view_name then
        print_error("[ViewManager] 请指定view_name!")
    end

    self.view_list[view_name] = view
end

-- 反注册一个界面
function ViewManager:UnRegisterView(view_name)
    self.view_list[view_name] = nil
end

-- 获取一个界面
function ViewManager:GetView(view_name)
    return self.view_list[view_name]
end

-- 界面是否打开
function ViewManager:IsOpen(view_name)
    if nil == self.view_list[view_name] then
        return false
    end

    return self.view_list[view_name]:IsOpen()
end

function ViewManager:IsOpenByIndex(view_name, index)
    -- body
    if not self:IsOpen(view_name) then
        return false
    end
    local view = self:GetView(view_name)
    return view:GetShowIndex() == index
end

-- 界面是否打开
function ViewManager:HasOpenView()
    local list = self.open_view_list[UiLayer.Normal]
    if nil == list then
        return false
    end

    for k,v in pairs(list) do
        if v:CanActiveClose() and v:IsOpen() then
            return true
        end
    end

    -- 任务章节界面
    if self:IsOpen(GuideModuleName.TipsShowChapterView) then
        return true
    end

    return false
end
-- 刷新打开的界面(反注册一个界面)
function ViewManager:HasOpenAndFlushView(view_name)
    local list = self.open_view_list[UiLayer.Normal]
    if nil == list then
        return
    end

    for k,v in pairs(list) do
        if v:CanActiveClose() and v:IsOpen()  then
            v:Flush()
        end
    end
end

-- 打开界面
function ViewManager:Open(view_name, tab_index, key, values)
    -- 用于给投放录视频用的，拦截所有界面打开
    if MIANUI_VIEW_EDITOR_FLAG then
        return
    end

    local now_view = self.view_list[view_name]
    if nil ~= now_view then
        local index = 0
        if tonumber(tab_index) == nil and type(tab_index) == 'string' then
            index = TabIndex[tab_index]
        else
            index = tonumber(tab_index)
        end

        --活动界面特殊处理
        if view_name == GuideModuleName.ActivityDetail then
            ActivityCtrl.Instance:ShowDetailView(index)
            return
        end
        local fun_name = FunOpen.Instance:GetFunNameByViewName(view_name) or view_name
        local is_open, tips = FunOpen.Instance:GetFunIsOpened(fun_name)

        if is_open ~= true then --模块功能未开启
            SysMsgCtrl.Instance:ErrorRemind(tips)
            return false
        end

        if TabIndex[tab_index] ~= nil and TabIndex[tab_index] ~= "" then
            local is_tab_fun_open, tip = FunOpen.Instance:GetFunIsOpenedByTabName(tab_index)
            if is_tab_fun_open ~= true then --标签功能未开启
                SysMsgCtrl.Instance:ErrorRemind(tip)
                return false
            end
        end

        if is_open then
            if values ~= nil then
                now_view:Flush(index, key, values)
            end
            now_view:Open(index, values ~= nil)
        else
            tips = (tips and tips ~= "" and tips) or Language.Common.FunOpenTip
            SysMsgCtrl.Instance:ErrorRemind(tips)
        end
    end
end

-- 配表打开界面
function ViewManager:OpenByCfg(cfg, data, flush_key)
    if cfg == nil then
        return
    end

    local t = Split(cfg, "#")
    local view_name = t[1]
    local tab_index = t[2]

    -- 判断功能开启
    -- if TabIndex[tab_index] == TabIndex.baoju_medal and not OpenFunData.Instance:CheckIsHide("baoju_medal") then
    -- 	TipsCtrl.Instance:ShowSystemMsg(Language.Common.FuncNoOpen)
    -- 	return
    -- end

    local param_t = {
        open_param = nil,			--打开面板参数
        sub_view_name = nil,		--打开二级面板
        to_ui_name = 0,				--跳转ui
        to_ui_param = 0,			--跳转ui参数
    }
    param_t.item_id = data and data.item_id or 0
    if t[3] ~= nil then
        local key_value_list = Split(t[3], ",")
        for k,v in pairs(key_value_list) do
            local key_value_t = Split(v, "=")
            local key = key_value_t[1]
            local value = key_value_t[2]

            if key == "sub" then
                param_t.sub_view_name = value
            elseif key == "op" then
                param_t.open_param = value
            elseif key == "uin" then
                param_t.to_ui_name = value
            elseif key == "uip" then
                param_t.to_ui_param = value
            end
        end
    end
    local index = TabIndex[tab_index]
    if tonumber(tab_index) then
        index = tonumber(tab_index)
    end
    self:Open(view_name, index, flush_key or "all", param_t, tab_index)
end

-- 关闭界面
function ViewManager:Close(view_name, ...)
    local now_view = self.view_list[view_name]
    if nil ~= now_view then
        now_view:Close(...)
    end
end

-- 关闭所有界面
function ViewManager:CloseAll()
    for k,v in pairs(self.view_list) do
        if v:CanActiveClose() then
            if v:IsOpen() then
                --如果是赏金玩法界面并且进去副本，就不关闭此界面
                if not (k == GuideModuleName.TaskDiaoYuView and (Scene.Instance:GetSceneId() == 9616 or Scene.Instance:GetSceneId() == 9617 or Scene.Instance:GetSceneId() == 9618)) then
                    v:Close()
                end
            end
        end
    end
end

function ViewManager:ForceCloseAll()
    for k,v in pairs(self.view_list) do
        if v:IsOpen() then
            v:Close()
        end
    end
end

-- 关闭界面
function ViewManager:CloseAllViewExceptViewName(view_name, value)
    local no_view_name = view_name
    if no_view_name == GuideModuleName.ActivityDetail then
        local act_id = tonumber(value)
        if act_id ~= nil then
            if act_id == ACTIVITY_TYPE.KF_ONEVONE then
                no_view_name = GuideModuleName.KuaFu1v1
            elseif act_id == ACTIVITY_TYPE.CLASH_TERRITORY then
                no_view_name = GuideModuleName.ClashTerritory
            end
        end
    end

    for k, v in pairs(self.view_list) do
        if v:CanActiveClose() and k ~= no_view_name then
            if v:IsOpen() then
                v:Close()
            end
        end
    end
end

-- 是否可以显示该UI
function ViewManager:CheckShowUi(view_name, index, tab_index)
    local can_show_view = true
    local tips = ""
    -- if IS_ON_CROSSSERVER then
    -- 	if view_name then
    -- 		-- 跨服中是否可以打开
    -- 		can_show_view, tips = CrossServerData.Instance:CheckCanOpenInCross(view_name)
    -- 	end
    -- end
    -- if view_name and can_show_view and OpenFunData.Instance then
    -- 	can_show_view, tips = OpenFunData.Instance:CheckIsHide(string.lower(view_name))
    -- end
    -- local can_show_index = true
    -- if index and can_show_view then
    -- 	local check_index = tab_index or index
    -- 	can_show_index, tips = OpenFunData.Instance:CheckIsHide(check_index)
    -- end
    return true
end

-- 刷新界面
function ViewManager:FlushView(view_name, ...)
    local now_view = self.view_list[view_name]
    if nil ~= now_view then
        now_view:Flush(...)
    end
end

-- 获得UI节点
function ViewManager:GetUiNode(view_name, node_name)
    local now_view = self.view_list[view_name]
    if nil ~= now_view then
        return now_view:OnGetUiNode(node_name)
    end
    return nil
end

function ViewManager:AddOpenView(view)
    self:RemoveOpenView(view, true)
    self.open_view_list[view:GetLayer()] = self.open_view_list[view:GetLayer()] or {}
    table.insert(self.open_view_list[view:GetLayer()], view)

    self:CheckViewRendering()

    MemoryManager.Instance:AddOpenView(view)

    if view:IsViewAffectUIRoleModelShadow() then
        table.insert(self.ui_role_model_view_list, view)
        self:CheckUIModelShadowVisible()
    end
end

function ViewManager:RemoveOpenView(view, ignore)
    if nil == self.open_view_list[view:GetLayer()] then
        return
    end

    for k, v in ipairs(self.open_view_list[view:GetLayer()]) do
        if v == view then
            v.__sort_order__ = 0
            table.remove(self.open_view_list[view:GetLayer()], k)
            break
        end
    end
    if not ignore then
        self:CheckViewRendering()
        MemoryManager.Instance:RemoveOpenView(view)
    end

    if view:IsViewAffectUIRoleModelShadow() then
        for k, v in ipairs(self.ui_role_model_view_list) do
            if v == view then
                table.remove(self.ui_role_model_view_list, k)
                break
            end
        end

        self:CheckUIModelShadowVisible()
    end
end

local is_full_screen = false
local can_inactive = false
local view = nil
local is_open = false
local is_rendering = false
local task_view = nil
local task_view_isopen = false
local unlock_view = nil
local unlock_view_isopen = false
local is_mid_camera_view = false
local screen_shot_view = nil
local snap_shot_view = nil
local screen_shot_view_isopen = false
function ViewManager:CheckViewRendering()
    is_full_screen = false
    is_mid_camera_view = false
    task_view = task_view or self:GetView(GuideModuleName.TaskDialog)
    task_view_isopen = task_view and task_view.is_real_open
    unlock_view = unlock_view or self:GetView(GuideModuleName.Unlock)
    unlock_view_isopen = unlock_view and unlock_view.is_real_open

    unlock_view = unlock_view or self:GetView(GuideModuleName.Unlock)
    unlock_view_isopen = unlock_view and unlock_view.is_real_open

    screen_shot_view = screen_shot_view or self:GetView(GuideModuleName.ScreenShotView)
    snap_shot_view = snap_shot_view or self:GetView(GuideModuleName.SnapShotView)
    screen_shot_view_isopen = (screen_shot_view and screen_shot_view:IsOpen()) or (snap_shot_view and snap_shot_view:IsOpen())

    if nil == task_view_isopen and task_view then
        task_view_isopen = task_view.is_open
    end

    if nil == unlock_view_isopen and unlock_view then
        unlock_view_isopen = unlock_view.is_open
    end

    for i=UiLayer.MaxLayer, 0, -1 do
        if self.open_view_list[i] then
            for j=#self.open_view_list[i], 1, -1 do
                view = self.open_view_list[i][j]
                can_inactive = false
                if view then
                    if view.view_name ~= GuideModuleName.TaskDialog
                            and view.view_name ~= ViewName.TipsDisconnectedView
                            and view.view_name ~= GuideModuleName.TipsPowerChangeView
                            and view.view_name ~= GuideModuleName.TipsDisconnectedView
                            and view.view_name ~= GuideModuleName.LoadingTips
                            and view.view_name ~= GuideModuleName.Unlock
                            and view.view_name ~= GuideModuleName.PowerChange
                            and view.view_name ~= GuideModuleName.SceneLoading
                            and view.view_name ~= GuideModuleName.ScreenShotView
                            and view.view_name ~= GuideModuleName.YuBiaoJieSuan
                            and view.view_name ~= GuideModuleName.SnapShotView then
                        if unlock_view_isopen and view.view_name ~= GuideModuleName.MainUIView and
                                view.view_name ~= GuideModuleName.MainUIViewLeftTop and view.view_name ~= GuideModuleName.MainUIViewRightTop and view.view_name ~= GuideModuleName.MainUIViewRightDown
                                and view.view_name ~= GuideModuleName.MainUIViewLeftDown
                        then
                            can_inactive = true
                        elseif is_full_screen or (task_view_isopen and not BaseView.NotCloseViewByOnlyView(view.view_name)) then
                            can_inactive = true
                        elseif screen_shot_view_isopen then
                            can_inactive = true
                        end
                    end

                    if nil ~= view.is_real_open then
                        is_open = view.is_real_open
                    else
                        is_open = view.is_open
                    end

                    is_rendering = view:IsRendering()
                    if is_open and is_rendering ~= not can_inactive then
                        view:SetRendering(not can_inactive)
                        if not is_rendering and not can_inactive and view.root_node then
                            -- if view.animator ~= nil then
                            -- 	view.animator:SetBool(AnimatorConvert:ToInt("show"), true)
                            -- end
                            -- 重置坐标位置
                            -- local transform = view.root_node.transform
                            -- transform:SetLocalScale(1, 1, 1)
                            -- local rect = transform:GetComponent(typeof(UnityEngine.RectTransform))
                            -- if rect then
                            -- 	rect.anchorMax = Vector2(1, 1)
                            -- 	rect.anchorMin = Vector2(0, 0)
                            -- 	rect.anchoredPosition3D = Vector3(0, 0, 0)
                            -- 	rect.sizeDelta = Vector2(0, 0)
                            -- end
                            local show_index = view:GetShowIndex()
                            if view.IsLoadedIndex and view:IsLoadedIndex(show_index) then
                                -- 注意新的baseView没有必要再执行下面的代码了。因为没有隐藏，直接移开。
                                -- ShowIndexCallBack随意调将引入不可控因素，导致bug产生
                                if nil == view.view_render then
                                    view:ShowIndexCallBack(show_index)
                                end
                            end
                        end
                    end
                    -- if not is_mid_camera_view and view.camera_mode == UICameraMode.UICameraMid and not view.full_screen and not is_full_screen then
                    -- 	is_mid_camera_view = true
                    -- end
                    if (view.full_screen or view.is_big_view) and not is_full_screen and not task_view_isopen and not unlock_view_isopen then
                        is_full_screen = true
                    end
                end
            end
        end
    end

    BaseView.UpdateOpenViewActive()
    local is_scene_visible = task_view_isopen or not is_full_screen
    if is_scene_visible then
        AssetBundleMgr:ReqLowLoad()
    else
        AssetBundleMgr:ReqHighLoad()
    end

    if Scene.Instance ~= nil and not Scene.Instance:IsSceneLoading() and FightText.Instance then
        --不要再用这个，全屏界面已经使用SnapShot，可以快速关闭场景摄象机，又不会花屏
        -- Scene.Instance:SetSceneVisible(is_scene_visible)
        FightText.Instance:SetActive(is_scene_visible)
    end

    -- Close the ui scene.
    if not is_full_screen and UIScene.scene_asset then
        UIScene:ChangeScene(nil)
    end
end

-- 界面是否打开 返回键导航kr
function ViewManager:OpenViewCloseByStep()
    for i = UiLayer.MaxLayer, UiLayer.MainUILow, -1 do
        local list = self.open_view_list[i]
        if nil ~= list then
            local count = #list
            for k = count, 1, -1 do
                if list[k]:CanActiveClose() and list[k]:IsOpen() then
                    if list[k].view_name ~= GuideModuleName.Login
                            and list[k].view_name ~= GuideModuleName.DaZuoExpView then --

                        list[k]:Close()
                        return true
                    elseif list[k].view_name == GuideModuleName.Login then
                        if LoginView.Instance:AppQuickCheck() then
                            return true
                        end
                    end
                end
            end
        end
    end
    -- 任务章节界面
    if self:IsOpen(GuideModuleName.TipsShowChapterView) then
        self:Close(GuideModuleName.TipsShowChapterView)
        return true
    end


    return false
end

-- 现只考虑UiLayer.Normal层，其他层应该不会有ui模型。最上面的界面才显示模型影子
function ViewManager:CheckUIModelShadowVisible()
    local length = #self.ui_role_model_view_list
    if length <= 0 then
        return
    end

    local last_view = self.ui_role_model_view_list[length]
    if last_view.ResetUIRoleModelShadowVisibleState then
        last_view:ResetUIRoleModelShadowVisibleState()
    end

    for k = 1, length - 1 do
        local view = self.ui_role_model_view_list[k]
        if view.SetUIRoleModelShadowVisible then
            view:SetUIRoleModelShadowVisible(false)
        end
    end
end