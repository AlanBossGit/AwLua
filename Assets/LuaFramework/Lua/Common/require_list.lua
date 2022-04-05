local lua_file_list = {
    "Common/define",                             --负责lua_ctrl类名
    "Common/debugtool",                          --Debug调试工具
    "MyClass/systool/BindTool",                     --函数绑定
    "MyClass/uicontroller/BaseView",             --UI_View的基类
    "MyClass/uicontroller/BaseViewRender",       --UI_View对象类


    ----"Logic/CtrlManager",                       --UI控制注册类
    --"MyClass/common/ManagerCenter",              --管理器控制类

    --例子模式：public const bool ExampleMode = true；时才开起
    --"Controller/PromptCtrl",
    --"Controller/MessageCtrl",

    --ui控制类
    "MyClass/game/TestGameDemo/test_game_ctrl",

}

return lua_file_list