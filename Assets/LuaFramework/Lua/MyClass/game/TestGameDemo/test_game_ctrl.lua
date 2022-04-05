require("MyClass/game/TestGameDemo/test_game_data")
require("MyClass/game/TestGameDemo/test_game_view")
TestGameCtrl = class("TestGameCtrl")

function TestGameCtrl:initialize()

end

function TestGameCtrl:__init()
    self.view = TextGameView:new()
    self.data = TextGameData:new()
end

function TestGameCtrl:__delete()
   -- print_log("TestGameCtrl:__delete()")
end

function TestGameCtrl:Update(time, delta_time)

end