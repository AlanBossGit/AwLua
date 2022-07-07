ModulesController = ModulesController or BaseClass()


function ModulesController:__init(is_quick_login)
    if ModulesController.Instance then
        print_error("ModulesController.Instance 对象为空")
        return
    end
    ModulesController.Instance = self
    self.ctrl_list = {}
    self.push_list = {}
    self.cur_index = 0
    self:CreateCoreModule()

    self:Star()
end

function ModulesController:__delete()
    self:DeleteControllers()
    self:DeleteCoreModule()
end

--实力化核心模块类：
function ModulesController:CreateCoreModule()
    UIManager.New()            -- UI面板管理类
    ManagerCenter.New()        -- 管理器控制类（C#）
end

--移除核心类:
function ModulesController:DeleteCoreModule()
    UIManager.Instance:DeleteMe()
    ManagerCenter.Instance:DeleteMe()
end

function ModulesController:Star(call_back)
    self.state_callback = call_back --加载状态回调
    --游戏逻辑控制器
    self.push_list = {
        TestGameCtrl,   --测试控制类：
    }
    PushCtrl(self)
end

function ModulesController:Update(now_time, elapse_time)
    for i = 1, 12 do
        if self.cur_index < #self.push_list then
            self.cur_index = self.cur_index + 1
            table.insert(self.ctrl_list,self.push_list[self.cur_index].New())
        end
        if self.cur_index >= #self.push_list then
            --self:OnAllCtrlInited()
            PopCtrl(self)
            --print("—————————— ModulesController:Update(now_time, elapse_time)——————————",UIViewName.testViews)
            UIManager.Instance:Open(UIViewName.testView,0)
            break
        end
    end

    --返回加载进度：
    if self.state_callback then
        self.state_callback(self.cur_index / #self.push_list)
    end
end


function ModulesController:OnAllCtrlInited()
    for k,v in pairs(self.ctrl_list) do
        if v.OnAllCtrlInited then
            v:OnAllCtrlInited()
        end
    end
end

function ModulesController:Stop()

end

--删除模块控制器
function ModulesController:DeleteControllers()
    local count = #self.ctrl_list
    for i = count, 1, -1 do
        self.ctrl_list[i]:DeleteMe()
    end
    self.ctrl_list = {}
end
