--模块预制体类
BaseViewRender = BaseViewRender or BaseClass()


function BaseViewRender:__init()
    self.view_name = "none_name"            --模块名字
    self.root_node = nil                    --模块节点（BaseView）
    self.root_node_transform = nil          --模块节点Transform
    self.root_canvas = nil                  --模块节点Canvas
    self.root_transform = nil               --模块（Root）子节点Transform
    self.clear_z_obj = nil                  --z轴层级处理
    self:ResetNodeList()                    --重置初始化node_list
end


function BaseViewRender:__delete()

end


--删除所有节点
function BaseViewRender:DestroyAllNode()
    if self.root_node then
        self.root_node = nil
    end
    self:ResetNodeList()
end

--重置node_list
function BaseViewRender:ResetNodeList()
    --节点树列表，通过名字索引，指向node_list中的name
    self.node_list = setmetatable({},{_index = function(table,key)
        local value = rawget(table,key) or rawget(self.node_cache,key)
        if value then
            return value
        end
        --缓存处理：
        for _,tbl in pairs(self.node_list) do
            value = tbl[key]
            if value then
                self.node_cache[key] = value
                return value
            end
        end
        return nil
    end})
    self.node_cache = {}
end

--设置模块名字：
function BaseViewRender:SetViewName(view_name)
    self.view_name = view_name
end

--创建模块节点：
function BaseViewRender:TryCreateRooNode()
    if nil ~= self.root_node then
        return self.root_node, self.root_canvas, self.root_transform, self.node_list
    end
    --实力化一个模块到UI层下：
    local uiMgr = UIManager.Instance
    self.root_node = newObject(uiMgr:GetUIObjPrefab(),Vector3.zero,Quaternion.identity,uiMgr:GetRootParent().transform)
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