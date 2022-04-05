
---@class TimerQuest : BaseClass
TimerQuest = TimerQuest or BaseClass()

function TimerQuest:__init()
    self.quest_list = {}
    self.check_callback_map = {}
    self.check_handle_map = {}
    self.execute_callback_list = {}

    self.quest_info_pool = {}
    self.next_quest_id = 1

    Runner.Instance:AddRunObj(self, 4)
end

function TimerQuest:__delete()
    self.quest_list = {}
    Runner.Instance:RemoveRunObj(self)
end

function TimerQuest:Update(now_time, elapse_time)
    local excute_num = 0

    for k, v in pairs(self.quest_list) do
        if v[4] <= 0 then
            self.quest_list[k] = nil
            self:DelCheckQuest(k)
            self:ReleaseQuestInfoToPool(v)
        else
            if v[3] <= now_time then
                excute_num = excute_num + 1
                self.execute_callback_list[excute_num] = k
                v[3] = now_time
                v[3] = v[3] + v[2]
                v[4] = v[4] - 1
            end
        end
    end

    local quest = nil
    for i=1, excute_num do
        local quest = self.quest_list[self.execute_callback_list[i]]
        self.execute_callback_list[i] = nil
        if nil ~= quest then
            Trycall(quest[1], quest[5]) 	-- 逻辑中尽是报错，如果一个出现报错，将影响其他地方出现BUG
        end
    end
end

function TimerQuest:GetQuestInfoFromPool(quest_id, callback, delay_time, times, cbdata)
    local quest_info = table.remove(self.quest_info_pool)
    if quest_info == nil then
        quest_info = {}
    end
    quest_info[1] = callback
    quest_info[2] = delay_time
    quest_info[3] = Status.NowTime + delay_time
    quest_info[4] = times
    quest_info[5] = cbdata
    quest_info[6] = quest_id
    return quest_info
end

function TimerQuest:ReleaseQuestInfoToPool(quest_info)
    if quest_info == nil then
        return
    end

    if #self.quest_info_pool >= 30 then
        return
    end

    quest_info[1] = nil
    quest_info[2] = nil
    quest_info[3] = nil
    quest_info[4] = nil
    quest_info[5] = nil
    quest_info[6] = nil
    table.insert(self.quest_info_pool, quest_info)
end

-- 内部用
function TimerQuest:AddDelayTimer(callback, delay_time, cbdata)
    return self:AddTimesTimer(callback, delay_time, 1, cbdata)
end

function TimerQuest:AddTimesTimer(callback, delay_time, times, cbdata)
    local quest_id = self.next_quest_id
    self.next_quest_id = self.next_quest_id + 1
    self.quest_list[quest_id] = self:GetQuestInfoFromPool(quest_id, callback, delay_time, times, cbdata)
    return quest_id
end

function TimerQuest:AddRunQuest(callback, delay_time)
    self.check_callback_map[callback] = callback
    local quest_id = self:AddTimesTimer(callback, delay_time, 999999999)

    self.check_callback_map[callback] = callback
    self.check_handle_map[quest_id] = callback

    return quest_id
end

function TimerQuest:InvokeRepeating(callback, start_time, delay_time, times)
    local quest_id = nil
    quest_id = self:AddDelayTimer(function ()
        callback()
        local quest_info = self:GetRunQuest(quest_id)
        if quest_info then
            quest_info[1] = callback
            quest_info[2] = delay_time
            quest_info[3] = Status.NowTime + delay_time
            quest_info[4] = times
        end
    end, start_time)
    return quest_id
end

function TimerQuest:CancelQuest(quest_id)
    if quest_id == nil then return end

    local quest_info = self.quest_list[quest_id]
    if quest_info and quest_info[6] == quest_id then
        self.quest_list[quest_id] = nil
        self:DelCheckQuest(quest_id)
        self:ReleaseQuestInfoToPool(quest_info)
    else
        if quest_info then
            print_error("TimerQuest:CancelQuest", quest_id, quest_info[6])
        end
    end
end

function TimerQuest:EndQuest(quest_id)
    if quest_id == nil then return end

    local quest_info = self.quest_list[quest_id]
    if quest_info and quest_info[6] == quest_id then
        local callback = quest_info[1]
        local cbdata = quest_info[5]
        self.quest_list[quest_id] = nil
        self:DelCheckQuest(quest_id)
        callback(cbdata)
        self:ReleaseQuestInfoToPool(quest_info)
    else
        if quest_info then
            print_error("TimerQuest:EndQuest", quest_id, quest_info[6])
        end
    end
end

function TimerQuest:GetRunQuest(quest_id)
    if quest_id == nil then
        return nil
    end

    local quest_info = self.quest_list[quest_id]
    if not quest_info or quest_info[6] ~= quest_id then
        return nil
    end

    return quest_info
end

function TimerQuest:IsExistsListen(callback)
    return nil ~= self.check_callback_map[callback]
end

function TimerQuest:DelCheckQuest(quest_id)
    if nil ~= self.check_handle_map[quest_id] then
        self.check_callback_map[self.check_handle_map[quest_id]] = nil
        self.check_handle_map[quest_id] = nil
    end
end

function TimerQuest:GetQuestCount(t)
    t.time_quest_count = 0
    for k,v in pairs(self.quest_list) do
        t.time_quest_count = t.time_quest_count + 1
    end
end

-- 增加延迟调用，在在obj的生命周期结束后将自动移除
function AddDelayCall(obj, callback, delay_time)
    obj.__delay_call_times = obj.__delay_call_times or 0
    obj.__delay_call_times = obj.__delay_call_times + 1
    local key = "__delay_call_times_" .. obj.__delay_call_times % 1000
    ReDelayCall(obj, callback, delay_time, key)
end

-- 延迟调用，将移除obj持有的上一个同key的延迟
function ReDelayCall(obj, callback, delay_time, key)
    __DelayCall(obj, callback, delay_time, key, true)
end

-- 延迟调用，如果当前已有，则不移除上次延迟，等上次延迟执行
function TryDelayCall(obj, callback, delay_time, key)
    __DelayCall(obj, callback, delay_time, key, false)
end

function __DelayCall(obj, callback, delay_time, key, is_recall)
    if "table" ~= type(obj) then
        print_error("[DelayCall]参数错误，请指定正确的obj")
        return
    end

    if "table" ~= type(obj) or nil == obj.DeleteMe then
        print_error("[DelayCall]参数错误，请指定正确的obj")
        return
    end


    if nil == callback then
        print_error("[DelayCall]参数错误，请指定正确的callback")
    end

    if nil == key then
        print_error("[DelayCall]参数错误，请指定唯一的key以便可移除旧的，不需移除请使用AddDelayCall")
        return
    end

    if nil == obj.__delay_call_map then
        obj.__delay_call_map = {}
    end

    if nil ~= obj.__delay_call_map[key] then
        if is_recall then
            GlobalTimerQuest:CancelQuest(obj.__delay_call_map[key])
            obj.__delay_call_map[key] = nil
        else
            return
        end
    end

    local quest_id = GlobalTimerQuest:AddDelayTimer(function ()
        obj.__delay_call_map[key] = nil
        callback()
    end, delay_time)

    obj.__delay_call_map[key] = quest_id
end

function CancleDelayCall(obj, key)
    if nil == obj or nil == obj.__delay_call_map or nil == key then
        return
    end

    GlobalTimerQuest:CancelQuest(obj.__delay_call_map[key])
    obj.__delay_call_map[key] = nil
end

function HasDelayCall(obj, key)
    if nil == obj or nil == obj.__delay_call_map or nil == key then
        return false
    end

    return obj.__delay_call_map[key] ~= nil
end

function CancleAllDelayCall(obj)
    if nil == obj or nil == obj.__delay_call_map or nil == GlobalTimerQuest then
        return
    end

    for k,v in pairs(obj.__delay_call_map) do
        GlobalTimerQuest:CancelQuest(v)
    end

    obj.__delay_call_map = nil
    obj.__delay_call_times = 0
end
