--模块预制体类
BaseViewRender = BaseViewRender or BaseClass()

function BaseViewRender:__init()
    self.view_name = "NewBaseView"          --模块名字
    self.root_node = nil                    --模块节点（BaseView）
    self.root_node_transform = nil          --模块节点Transform
    self.root_canvas = nil                  --模块节点Canvas
    self.root_transform = nil               --模块（Root）子节点Transform
    self.clear_z_obj = nil                  --z轴层级处理
    self.render_gameobj_t ={}
    self:ResetNodeList()                    --重置初始化node_list
end

function BaseViewRender:__delete()
    self.root_node = nil                    --模块节点（BaseView）
    self.root_node_transform = nil          --模块节点Transform
    self.root_canvas = nil                  --模块节点Canvas
    self.root_transform = nil               --模块（Root）子节点Transform
    self.clear_z_obj = nil                  --z轴层级处理
    self.render_gameobj_t = nil
    self:DestroyAllNode()
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
    self.node_list = setmetatable({},{__index = function(table,key)
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

--添加rend的信息
function BaseViewRender:AddRenderGameObjs(index, add_gameobj_list)
    local gameobj_list = self.render_gameobj_t[index]
    if nil == gameobj_list then
        gameobj_list = {}
        self.render_gameobj_t[index] = gameobj_list
    end

    local len = #gameobj_list
    for _, v in ipairs(add_gameobj_list) do
        local is_exists = false
        for i=1, len do
            if v == gameobj_list[i] then
                is_exists = true
                break
            end
        end

        if not is_exists then
            table.insert(gameobj_list, v)
            local name_table = v:GetComponent(typeof(AW.UINameTable))
            self.node_list[v.name] = U3DNodeList(name_table, self)
        end
    end
end

function BaseViewRender:RefreshGameObjActive(show_index)
    local active_gameobjs = {}
    for k, list in pairs(self.render_gameobj_t) do
        for _, gameobj in ipairs(list) do
            if k == 0 or show_index == k then
                active_gameobjs[gameobj] = true
                gameobj:SetActive(true)
            elseif nil == active_gameobjs[gameobj] then --同一个index下可能有不同的gameobj
                gameobj:SetActive(false)
            end
        end
    end
end

--创建模块节点：
function BaseViewRender:TryCreateRooNode()
    if nil ~= self.root_node then
        print_log("----》213",self.node_list)
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
    print_log("----》123",self.node_list)
    return self.root_node, self.root_canvas, self.root_transform, self.node_list
end