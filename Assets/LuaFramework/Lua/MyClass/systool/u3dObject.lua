local UserDataKey = "__userdata__"


--组件列表：
local component_table = {
    -- 基础组件
    transform = typeof(UnityEngine.Transform),
    camera = typeof(UnityEngine.Camera),
    renderer = typeof(UnityEngine.Renderer),
    animation = typeof(UnityEngine.Animation),
    animator = typeof(UnityEngine.Animator),
    collider = typeof(UnityEngine.Collider),
    audio = typeof(UnityEngine.AudioSource),
    light = typeof(UnityEngine.Light),
    line_renderer = typeof(UnityEngine.LineRenderer),

    -- UI相关组件
    layout_element = typeof(UnityEngine.UI.LayoutElement),
    rect = typeof(UnityEngine.RectTransform),
    canvas = typeof(UnityEngine.Canvas),
    canvas_group = typeof(UnityEngine.CanvasGroup),
    image = typeof(UnityEngine.UI.Image),
    raw_image = typeof(UnityEngine.UI.RawImage),
    text = typeof(UnityEngine.UI.Text),
    button = typeof(UnityEngine.UI.Button),
    toggle = typeof(UnityEngine.UI.Toggle),
    toggle_group = typeof(UnityEngine.UI.ToggleGroup),
    slider = typeof(UnityEngine.UI.Slider),
    scroll_rect = typeof(UnityEngine.UI.ScrollRect),
    input_field = typeof(UnityEngine.UI.InputField),
    dropdown = typeof(UnityEngine.UI.Dropdown),
    scroller = typeof(EnhancedUI.EnhancedScroller.EnhancedScroller),
    accordion_element = typeof(AccordionElement),
    grayscale = typeof(UIGrayscale),
    rich_text = TypeRichTextGroup,
    grid_layout_group = typeof(UnityEngine.UI.GridLayoutGroup),
    playable_director = typeof(UnityEngine.Playables.PlayableDirector),
    shadow = typeof(UnityEngine.UI.Shadow),
    uiname_table = typeof(UINameTable),
    out_line = typeof(UnityEngine.UI.Outline),
    gradient = typeof(UIGradient),

    -- 自定义UI组件

    -- 自定义3D组件
}

--创建一个元表
local function create_component_metable(component, index, userdata)
    return setmetatable(
            {
                __meta__ = component,
                is_component = true,
                [UserDataKey] = userdata,
            },

            {
                __index = index,
                __newindex = function(t, k, v)
                    component[k] = v
                end
            })
end

local u3d_metatable = {
    __index = function(table,key)
        if IsNil(table.gameObject) then
            return nil
        end
        local key_type = component_table[key]
        if key_type ~= nil then
            local commpoent = table.gameObject:Getcompoent(key_type)
            if commpoent ~= nil then
                local metatable = component_table[key_type]
                local data
                if metatable ~= nil then
                    data = create_component_metable(commpoent,metatable,table[UserDataKey])
                else
                    data = commpoent
                end
                table[key] = data
                return data
            end

        end
    end
}

function _G:U3DObject(go,transform,userdata)
    if nil == go then
        return nil
    end
    local obj = {gameObject = go ,transform = transform ,[userdata] = userdata}
    setmetatable(obj,u3d_metatable)
    return obj
end

--获取对象身上的UINameTable组件，并存于node_list中
function U3DNodeList(name_table,userdata)
    local node_list = {}
    if nil ~= name_table then
        local map = name_table.Lookup
        local iter = map:GetEnumerator()
        while iter:MoveNext() do
            local cuurrent = iter.Current
            node_list[cuurrent.key] = U3DObject(current.Value,nil,userdata)
        end
    end
    return node_list
end
