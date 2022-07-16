BaseRender = BaseRender or BaseClass()
function BaseRender:__init(obj)
    self.data = nil             --数据
    self.index = nil            --索引
    self.name = ""              --名字
    self.has_load = nil         --是否已经加载完成
    self.view = nil             --视图对象
    self.is_active = true       --是否显示
    self.flush_param_t = nil    --刷新变量
    self.key = nil              --key值
    self.root_node = nil        --节点
    if obj then
        self:SetView(obj)
    end
end

function BaseRender:__delete()
    self:ResetInfo()
    self:ReleaseCallBack()
end

function BaseRender:ResetInfo()
    self.data = nil             --数据
    self.index = nil            --索引
    self.name = ""              --名字
    self.has_load = nil         --是否已经加载完成
    self.view = nil             --视图对象
    self.is_active = true       --是否显示
    self.flush_param_t = nil    --刷新变量
    self.key = nil              --key值
    self.root_node = nil        --节点
end
-------------Star（基本信息设置）---------------------

function BaseRender:SetView(new_view)
    if (type(new_view) == "table" and not new_view.gameObject) or type(new_view) == "boolean" then
        return
    end

    --UI根节点，支持new_view是GameObject或者U3DObject
    if type(new_view) == "userdata" then
        self.view = U3DObject(new_view)
    else
        self.view = new_view
    end
    self.name_table = new_view:GetComponent(typeof(AW.UINameTable))
    self.node_list = U3DObject(self.name_table,self)
    self:LoadCallBack(new_view)
    if not self.is_active then
        self.view:SetActive(self.is_active)
    end
    self.has_load = true
    self:FlushHelper()
end

--数据刷新：
function BaseRender:FlushHelper()
    if nil == self.view or not self.has_load or nil == self.flush_param_t then
        return
    end

    local param_list = self.flush_param_t
    self.flush_param_t = nil
    self:OnFlush(param_list)
end

--查找组件：name_path：对象名（支持name/name/name的格式）
function BaseRender:FindObj(name_path)
    if nil == self.view then return end
    if nil ~= self.name_table then
        local game_obj = self.name_table:Find(name_path)
        if nil ~= game_obj then
            return U3DObject(game_obj)
        end
    end
    local transform self.view.transform:FindHard(name_path)
    if nil ~= transform then
        return U3DObject(transform.gameObject,transform)
    end
end


function BaseRender:SetKey(key)
    self.key = key
end

function BaseRender:GetKey()
    return self.key
end
--获得Transform:
function BaseRender:GetTransform()
    if not self.view then
        print_error("对象为空")
    end
    return self.view.tranform
end

--获得预制体对象：
function BaseRender:GetView()
    return self.view.gameObject
end

--获得数据：
function BaseRender:GetData()
    return self.data
end

--设置数据：　
function BaseRender:SetData(data)
    self.data = data
    if self.has_load then
        --self:OnFlush()
    else
        --self:
    end
end

--设置父物体：
function BaseRender:SetParent(node,isWorldPos)
    if not self.view then
        print_error("对象为空")
    end
    self.root_node = node
    self.view.transform:SetParent(node,isWorldPos)
end

--获取父物体节点：
function BaseRender:GetRootNode()
    return self.root_node
end

--清空数据：
function BaseRender:ClearData()
    self:SetData(nil)
end

--获取名字：
function BaseRender:GetName()
    return self.name
end

--设置名字：
function BaseRender:SetName(name)
    self.name = name
end

--设置世界位置：
function BaseRender:SetPosition(x, y)
    Transform.SetPosition(self.view.transform,u3dpool.vec3(x,y,0))
end

--设置本地位置：
function BaseRender:SetLocalPosition(x, y)
    Transform.SetLocalPosition(self.view.transform,u3dpool.vec3(x,y,0))
end

--设置锚点坐标：
function BaseRender:SetAnchoredPosition(x, y)
    local rect = self.view.transform:GetOrAddComponenet(typeof(UnityEngine.RectTransform))
    if rect then
        rect.anchoredPosition = Vector2(x, y)
    end
end

--设置大小：
function BaseRender:SetContentSize(w, h)
    self.view.rect.sizeDelta = Vector2(w, h)
end

--设置是否显示：
function BaseRender:SetVisible(is_visible)
    if is_visible ~= nil and self.view then
        self.view:SetActive(is_visible)
    end
end
-------------End（基本信息设置）-------------------







-------------Star(可重写接口)----------------------
function BaseRender:LoadCallBack(new_view)
	-- override
end

-- 刷新(用Flush刷新OnFlush的方法必须是有用LoadCallBack加载完成的时候使用,否则有可能引起报错)
function BaseRender:OnFlush(param_list)
    -- override
end

--清除数据
function BaseRender:ReleaseCallBack()
    -- override
end
-------------End(可重写接口)------------------------