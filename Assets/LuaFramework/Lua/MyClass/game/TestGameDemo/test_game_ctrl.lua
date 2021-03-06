require("MyClass/game/TestGameDemo/test_game_data")
require("MyClass/game/TestGameDemo/test_game_view")
TestGameCtrl = TestGameCtrl or BaseClass()

function TestGameCtrl:__init()
    self.view = TextGameView.New(UIViewName.testView)
    self.data = TextGameData.New()
end

function TestGameCtrl:__delete()
    if self.view then
        self.view:DeleteMe()
        self.view = nil
    end
    if  self.data then
        self.data:DeleteMe()
        self.data = nil
    end
end


