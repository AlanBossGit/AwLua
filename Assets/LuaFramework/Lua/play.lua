--负责处理类：
Play = Play or {
    ctrl_state = CTRL_STATE.START,
    module_list = {},
}

function Play:Star(call_back)
    local modules_controller = ModulesController.New() -- 游戏模块
    table.insert(self.module_list,modules_controller)
    modules_controller:Star(function()
        if self.complete_callback then
            self.complete_callback()
            self.complete_callback = nil
        end
    end)
end

function Play:Update(now_time, elapse_time)
    if self.ctrl_state == CTRL_STATE.UPDATE then

    elseif self.ctrl_state == CTRL_STATE.START then
        self.ctrl_state = CTRL_STATE.NONE
        self:Star(function()
            self.ctrl_state = CTRL_STATE.UPDATE
        end)
    elseif self.ctrl_state == CTRL_STATE.STOP then
        self.ctrl_state = CTRL_STATE.NONE
        self:Stop()
        PopCtrl(self)
    end
end

function Play:Stop()
    local count  = #self.module_list
    for i = count, 1 ,-1 do
        self.module_list[i]:DeleteMe()
    end
    self.module_list = {}
    self.complete_callback = nil
end

function Play:SetComplete(complete_callback)
    self.complete_callback = complete_callback
end

return Play