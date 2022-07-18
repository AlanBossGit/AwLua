TextGameView = TextGameView or BaseClass(BaseView)

function TextGameView:__init()
   self:AddViewResource(0,"ui/test/testPanel","testPanel");

end


function TextGameView:__delete()

end

function TextGameView:LoadCallBack()
    --self.resMgr =  ManagerCenter.Instance:GetManager(CS_ManagerNames.Resource)
    --self.resMgr:LoadAssetAsync("ui/img/warrior_woman", {"warrior_woman"}, typeof(UnityEngine.Sprite), function(sr)
    --    print_error("-------------->>>",sr)
    --end)
    XUI.AddClickEventListener(self.node_list["TestButton"],function()
        self:OnClickGetReward()
    end)
end

function TextGameView:OnFlush()
end

function TextGameView:OnClickGetReward()
    print_error("点击了按钮")
end
function TextGameView:LoadIndexCallBack()
end