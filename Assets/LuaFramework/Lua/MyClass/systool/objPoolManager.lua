-----------对象池
ObjPoolManager = ObjPoolManager or BaseClass()

function ObjPoolManager:__init()
    ObjPoolManager.Instance = self
    self.cache_list = {}    --缓存的列表
    self.obj_list = {}      --对象列表
end

function ObjPoolManager:__delete()
    ObjPoolManager.Instance = nil

    if #self.cache_list>0 then
        for k,v in pairs(self.cache_list) do
            v:DeleteMe()
        end
        self.cache_list = nil    --缓存的列表
    end
    self.obj_list = nil     --对象列表
    if self.resMgr then
        self.resMgr:DeleteMe()
        self.resMgr = nil
    end
end

function ObjPoolManager:CreateObj(bundle_name,asset_name,onfinish,onfail)
    local key = bundle_name .."_"..asset_name
    if self.cache_list[key] then
        return self.cache_list[key].obj
    end

    if not self.resMgr then
        self.resMgr =  ManagerCenter.Instance:GetManager(CS_ManagerNames.Resource)
    end
    local go_render = BaseRender.New()
    self.cache_list[key] = go_render
    self.resMgr:LoadAssetAsync(bundle_name, {asset_name}, typeof(GameObject), function(objs)
        if not objs then
            local error_Str = string.format("资源加载失败：路径= %s,名称 = %s",bundle_name,asset_name)
            print_error(error_Str)
            onfail(error_Str)
            return
        end
        go_render:SetView(newObject(objs[0],Vector3.zero,Quaternion.identity))
        go_render:SetKey(key)
        onfinish(go_render)
    end)
end

--################ ObjRender #################--

ObjectRender = ObjectRender or BaseClass(BaseRender)


function ObjectRender :__init()

end

function ObjectRender:__delete()

end