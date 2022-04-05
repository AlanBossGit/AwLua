TextGameView = class("TextGameView")

function TextGameView:initialize()
    panelMgr:CreatePanel('test', BindTool.Bind(self.OnCreate))
end

function TextGameView:OnCreate()
    print_log("创建Test预")
end


