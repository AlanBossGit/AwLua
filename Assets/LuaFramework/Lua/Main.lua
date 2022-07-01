
--游戏状态：
CTRL_STATE = {
	START = 0, --刚进入
	UPDATE = 1,--加载中
	FINISH = 2,--加载完成
	NONE = 3,
}
--存取带有生命周期的类：
local ctrl_list = {}

--是否为开发者模式
IsDevelopModel = true

--主入口函数。从这里开始lua逻辑
function Main()
--print("这是我的框架游戏")
end

--场景切换通知
function OnLevelWasLoaded(level)
	collectgarbage("collect")
	Time.timeSinceLevelLoad = 0
end

function OnApplicationQuit()
end



---------------------- 生命周期 ---------------------------

function GameUpdate()
	local time = UnityEngine.Time.unscaledTime
	local delta_time = UnityEngine.Time.unscaledDeltaTime
	if ctrl_list then
		for k, v in pairs(ctrl_list) do
			if v then
				v:Update(time, delta_time)
			end
		end
	end
end

function GameDestroy()
	--print("生命周期【GameDestroy】函数")
end

function GameFocus(hasFocus)
	--print("生命周期【GameFocus】函数")
end

function GamePause(pauseStatus)
	--print("生命周期【GamePause】函数")
end

function GameStop()
	--print("生命周期【GameStop】函数")
end

function QuitMain()
	--print("生命周期【QuitMain】函数")
end

function GameQuit()
	print("生命周期【GameQuit】函数")
	Trycall(function()
		for k, v in pairs(ctrl_list) do
			if v.Stop then
				v:Stop()
			end
		end
	end)
	IsDevelopModel = nil
end

-------------------------- end -------------------------------

function PushCtrl(ctrl)
	ctrl_list[ctrl] = ctrl
end

function PopCtrl(ctrl)
	ctrl_list[ctrl] = nil
end

--游戏入口
function GameStart()
	print("游戏入口")
end

-- 打印错误信息
function __TRACKBACK__(errmsg)
	local track_text = debug.traceback(tostring(errmsg));
	print(track_text .. "LUA ERROR");
	return false
end

--[[ 尝试调一个function 这个function可以带可变参数
如果被调用的函数有异常 返回false，退出此方法继续执行其他代码并打印出异常信息；]]
-- 这里直接提供参数，省GC和unpack性能
function Trycall(func, p1, p2, p3)
	return xpcall(func, __TRACKBACK__, p1, p2, p3);
end

--开始执行（游戏总入口）
GameStart()