local lua_file_list = {
    "Common/define",                             --负责lua_ctrl类名
    "Common/debugtool",                          --Debug调试工具
    "MyClass/Tool/BindTool",                     --函数绑定

    ----"Logic/CtrlManager",                       --UI控制注册类
    --"MyClass/common/ManagerCenter",              --管理器控制类

    --例子模式：public const bool ExampleMode = true；时才开起
    --"Controller/PromptCtrl",
    --"Controller/MessageCtrl",

    --ui控制类
    "MyClass/game/TestGameDemo/test_game_ctrl",

}

return lua_file_list