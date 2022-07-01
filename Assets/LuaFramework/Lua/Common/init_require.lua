

local InitRequire = {
    ctrl_state = CTRL_STATE.START,
    require_list = {},
    require_count = 0,
    require_index = 0,
}

function InitRequire:Start()
    -- 获取基础的require列表
    self.require_list = require("Common/require_list")
    for i = 1, #self.require_list do
        if nil ~= self.require_list[i] then
            local path = self.require_list[i]
            Trycall(function()
                print("导入的内容====>"..path)
                require(path)
            end, print_error)
            if not self:ExistLua(path) then
                print("不存在该Lua文件：",path)
            end
        end
    end
    self.ctrl_state = CTRL_STATE.FINISH
end

--判断是否已经加载过了
function InitRequire:ExistLua(lua_name)
    lua_name = string.gsub(lua_name, "/", "%.")
    return _G.package.loaded[lua_name] ~= nil
end

function InitRequire:Update(now_time, elapse_time)
    if  self.ctrl_state == CTRL_STATE.UPDATE then

    elseif self.ctrl_state == CTRL_STATE.START then
        self.ctrl_state = CTRL_STATE.UPDATE
        self:Start()
    elseif self.ctrl_state == CTRL_STATE.FINISH then
        self.ctrl_state = CTRL_STATE.NONE
        self:Finish()
        PopCtrl(self)
    end
end

function InitRequire:Finish()
    --例子模式：
    if AppConst.ExampleMode == 1 then
        local ctrl = ctrlMgr:GetCtrl(CtrlNames.Prompt);
        if ctrl ~= nil then
            ctrl:__init()
        end
    else
        --正式游戏:
        --local ctrl_list = ctrlMgr:GetAllCtrl()
        --for k,v in pairs(ctrl_list) do
        --    if v then
        --        v:__init()
        --    end
        --end
    end
end
return InitRequire