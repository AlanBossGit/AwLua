-- 场景相关事件
SceneEventType =
{
    SCENE_LOADING_STATE_ENTER = "scene_loading_state_enter",			-- 进入场景加载事件
    SCENE_LOADING_STATE_UDATAE = "scene_loading_state_update",			-- 进入场景加载事件
    SCENE_LOADING_STATE_QUIT = "scene_loading_state_quit",				-- 场景加载结束
    SCENE_CHANGE_COMPLETE = "scene_change_complete",					-- 场景改变事件
    UI_SCENE_LOADING_STATE_QUIT = "ui_scene_loading_state_quit",		-- UI场景加载结束
    SHOW_MAINUI_RIGHT_UP_VIEW = "show_mainui_right_up_view"	,			-- 主界面右上界面显示
    OBJ_ENTER_ROLE = "obj_enter_role",						            -- 物体进入角色视野
    OBJ_LEVEL_ROLE = "obj_level_role",						            -- 物体离开角色视野
    SCENE_ALL_LOAD_COMPLETE = "scene_all_load_complete",				-- 场景所有加载完成(主场景和细节场景)
    FLUSH_GUILD_SCENE_VIEW = "flush_guild_scene_view",                  -- 刷新帮派试炼面板
    CLOSE_LOADING_VIEW = "close_loading_view",                   		-- 关闭加载界面

    OBJ_ENTER_SHADOW = "obj_enter_shadow",								-- 机器人进入视野

    SCENE_LOGIC_ENTER = "scene_logic_enter"								-- common_scene_logic:enter
}