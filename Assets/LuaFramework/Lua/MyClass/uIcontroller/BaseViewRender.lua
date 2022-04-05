--模块预制体类
BaseViewRender = class("BaseViewRender")


function BaseViewRender:initialize()

end
function BaseViewRender:SetViewName(view_name)
    self.view_name = view_name
end

function BaseViewRender:TryCreateRooNode()
    if nil ~= self.root_node then
        return self.root_node, self.root_canvas, self.root_transform, self.node_list
    end
    --实力化一个模块到UI层下：
    local uiMgr = MgrCenter.GetManager(ManagerNames.UIManager)
    self.root_node = newObject(uiMgr:GetUIObjPrefab(),Vector3.zero,Vector3.zero,uiMgr:GetRootParent(),true)
    --名字赋值：
    self.root_node.name = self.view_name
    --获取其Canvas：
    self.root_canvas = self.root_node:GetComponent(typeof(UnityEngine.Canvas))
    self.root_node_transform = self.root_node.transform
    --UI面板节点：
    self.root_transform = self.root_node.transform:Find("Root")
    --z轴遮罩：
    local z_obj = self.root_node.transform:Find("UIClearZDepth")
    if not IsNil(z_obj) then
        self.clear_z_obj = z_obj:GetComponent(typeof(UnityEngine.UI.Image))
    end
    return self.root_node, self.root_canvas, self.root_transform, self.node_list
end