TextGameView = TextGameView or BaseClass(BaseView)

function TextGameView:__init()
    self:AddViewResource(0,"ui/testPanel","testPanel");

end


function TextGameView:__delete()

end


function TextGameView:LoadCallBack()
    --XUI.RemoveAllListener(self.node_list["TestButton"],BindTool.Bind(self.OnClickGetReward, self))
end

function TextGameView:OnFlush()
end

function TextGameView:OnClickGetReward()
    print_error("点击了按钮")
end
function TextGameView:LoadIndexCallBack()
end