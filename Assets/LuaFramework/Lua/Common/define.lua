--Ctrl类名称
CtrlNames = {
	Prompt = "PromptCtrl",
	Message = "MessageCtrl",
	TestGameDemo = "TestGameDemo",
}


--面板名称
PanelNames = {
	"PromptPanel",	
	"MessagePanel",
}


--协议类型--
ProtocalType = {
	BINARY = 0,
	PB_LUA = 1,
	PBC = 2,
	SPROTO = 3,
}


--来自C#层的管理器
CS_ManagerNames ={
	Shader = "ShaderManager",				--着色器管理器
	Resource = "ResourceManager",			--加载管理器
}

--来自lua层管理器的名称：
ManagerNames = {
	Ctrl = "CtrlManager",  					--注册UI面板的控制类
	BaseViewLoader = "BaseViewLoader",		--视图面板加载管理器
	UIManager = "UIManager",				--控制视图开关的管理器
}

--当前使用的协议类型--
TestProtoType = ProtocalType.BINARY;

Util = LuaFramework.Util;
AppConst = LuaFramework.AppConst;
LuaHelper = LuaFramework.LuaHelper;
ByteBuffer = LuaFramework.ByteBuffer;

resMgr = LuaHelper.GetResManager();
panelMgr = LuaHelper.GetPanelManager();	--老做法
soundMgr = LuaHelper.GetSoundManager();
networkMgr = LuaHelper.GetNetManager();

WWW = UnityEngine.WWW;
GameObject = UnityEngine.GameObject;