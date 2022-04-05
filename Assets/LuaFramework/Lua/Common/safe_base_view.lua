--#默认索引值：
local def_view_name_index = 10000
--#视图层级：
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
--视图关闭后缓存的时间：
ViewCacheTime = {
    LEAST = 5,
    NORMAL = 60,
    MOST = 3600,
}
--刘海适配区域
SafeAreaMode = {
    None = 0,
    Left = 1,
    Right = 2,
    Both = 3,
}
SafeBaseView = SafeBaseView or BaseClass()

function SafeBaseView:__init(view_name)
    if nil == view_name or "" == view_name then
        view_name = "safe_view_name"..def_view_name_index
        def_view_name_index = def_view_name_index + 1
    end


    self.view_name = view_name                      --视图模块名称
    self.view_layer = UiLayer.Normal                --视图层级
    self.view_cache_time = ViewCacheTime.LEAST      --视图关闭后缓存的时间
    self.show_index = -1                            --当前显示标签
    self.defilt_index = 0                           --默认显示的标签
    self.remind_tab = nil                           --每个标签对应的红点名称
    self.full_screen = false                        --是否全屏界面
    self.is_big_view = false                        --是否是大面板（大面板默认开启景深）
    self.is_need_depth = false                      --是否需要开启景深
    self.is_use_objpool = false                     --是否使用对象池（谨慎使用）
    self.is_aync_load = nil                         --是否异步加载
    self.is_use_cull_view = false                   --是否使用视图剔除
    self.is_close_anti_aliasing = true              --是否关闭抗锯齿
    self.is_tween_alpha = false                     --是否使用动画透明度

    self.is_open = false                            --是否被打开
    self.is_view_loaded = false                     --是否已经加载（index==0）
    self.is_safe_area_adapter = false               --是否刘海屏适配
    self.active_close = true                        --是否可以主动关闭（用于关闭所有界面的操作）
    self.is_maskbg_click = true                     --蒙板是可以点击
    self.flush_param_t = {}                         --界面刷新参数
    self.opened_index_t = {}                        --对应标签是否被打开过，关闭后清理
    self.node_list = {}                             --存取所有NameTab的值

    --self.view_loader =    --对象加载类
    --self.view_render =    --对象类
    --self.view_effect =    --特效处理类

    --注册视图
    ViewManager.Instance:RegisterView(self, view_name)
end











--#刘海处理：
function SafeBaseView.GetSafeAreaCanvas()
    if nil == SafeBaseView.safe_area_canvas_rect then
        local obj = ResMgr:Instantiate(BaseView.GetBaseViewParentTemplate()) --A
        obj.name = "SafeAreaCanvas"
        obj:SetActive(true)

        local transform = obj.transform
        obj:GetComponent(typeof(UnityEngine.UI.GraphicRaycaster)).enabled = false
        transform:SetParent(UILayer.transform, false)
        transform:SetLocalScale(1, 1, 1)

        local rect = transform:GetComponent(typeof(UnityEngine.RectTransform))
        rect.anchorMax = u3dpool.vec2(1, 1)
        rect.anchorMin = u3dpool.vec2(0, 0)
        rect.anchoredPosition3D = u3dpool.vec3(0, 0, 0)
        rect.sizeDelta = u3dpool.vec2(0, 0)

        local root = transform:Find("Root"):GetComponent(typeof(UnityEngine.RectTransform))
        SafeAreaAdpater.Bind(root.gameObject)   --A
        SafeBaseView.safe_area_canvas_rect = root
    end
    return SafeBaseView.safe_area_canvas_rect
end

--获得刘海的区域：
local zero_offset = Vector2(0, 0)
function SafeBaseView.GetSafeAreaMode()
    local safe_area_canvas_rect = SafeBaseView.GetSafeAreaCanvas()
    if IsNil(safe_area_canvas_rect) then
        return SafeAreaMode.None, zero_offset
    end

    -- 刘海屏在左边
    if safe_area_canvas_rect.offsetMin.x > 0 then
        return SafeAreaMode.Left, safe_area_canvas_rect.offsetMin
        -- 刘海屏在右边
    elseif safe_area_canvas_rect.offsetMax.x < 0 then
        return SafeAreaMode.Right, safe_area_canvas_rect.offsetMax
    end

    return SafeAreaMode.None, zero_offset
end
---end