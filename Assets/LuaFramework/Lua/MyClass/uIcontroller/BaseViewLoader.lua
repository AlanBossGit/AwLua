-- UI面板加载并存取类：
local BaseViewLoader = class("BaseViewLoader")

function BaseViewLoader:__init()
    self.list_panel = {}
end

function BaseViewLoader:__delete()
    print_log("BaseViewLoader:__delete()")
end

return BaseViewLoader