local CtrlManager =class("CtrlManager")
local ctrlList = {};


--控制器列表--
function CtrlManager:__init()
	logWarn("CtrlManager.Init----->>>");
	--例子模式：
	--CtrlManager.AddCtrl(CtrlNames.Message,MessageCtrl.New())
	--CtrlManager.AddCtrl(CtrlNames.Prompt,PromptCtrl.New())
    CtrlManager:AddCtrl(CtrlNames.TestGameDemo,TestGameCtrl:new())
end

--添加控制器--
function CtrlManager:AddCtrl(ctrlName, ctrlObj)
	if ctrlName == nil or ctrlObj == nil then
		print_error('CtrlManager:AddCtrl Error!! was nil.')
		return
	end
	ctrlList[ctrlName] = ctrlObj
	PushCtrl(ctrlList[ctrlName])
end

--获取控制器--
function CtrlManager:GetCtrl(ctrlName)
	return ctrlList[ctrlName]
end

--移除控制器--
function CtrlManager:RemoveCtrl(ctrlName)
	PopCtrl(ctrlList[ctrlName])
	ctrlList[ctrlName] = nil
end

--关闭控制器--
function CtrlManager:Close()
	for k,v in pairs(ctrlList) do
		PopCtrl(v)
	end
	ctrlList = nil
	--print_error('CtrlManager.Close---->>>');
end

--获取所有的注册的控制器--
function CtrlManager:GetAllCtrl()
 	return ctrlList
end


return CtrlManager