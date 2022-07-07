TextGameView = TextGameView or BaseClass(BaseView)

function TextGameView:__init()
    self:AddViewResource(0,"ui/testPanel",testPanel);

end


function TextGameView:__delete()
end


function TextGameView:LoadCallBack()
    self.AddViewResource(0,"","")
end
function TextGameView:OnFlush()
end

