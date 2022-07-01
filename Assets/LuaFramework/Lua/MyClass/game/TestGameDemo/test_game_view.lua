TextGameView = TextGameView or BaseClass(BaseView)

function TextGameView:__init(view_name)
    print_log("++ TextGameView:__init+++",view_name)
end


function TextGameView:__delete()
    print_log("+++TextGameView:__delete()")
end


function TextGameView:LoadCallBack()
    self.AddViewResource(0,"","")
end