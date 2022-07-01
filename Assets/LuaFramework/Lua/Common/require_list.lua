local lua_file_list = {
    "Common/define",                                --负责lua_ctrl类名
    "MyClass/systool/systool",                      --工具类
    "MyClass/common/ManagerCenter",                 --管理器（仅用于处理调用C#类）
    "MyClass/common/modules_controller",            --模块控制类
    "MyClass/uicontroller/uicontroller",            --UI控制器
    --例子模式：public const bool ExampleMode = true；时才开起
    --"Controller/PromptCtrl",
    --"Controller/MessageCtrl",

    --ui控制类
    "MyClass/game/TestGameDemo/test_game_ctrl",
}

return lua_file_list