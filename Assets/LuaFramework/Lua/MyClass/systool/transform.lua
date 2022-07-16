Transform = {}
function Transform.GetPosition(transform, position)
    if IsNil(transform) then return position end
    Vector3.SetTemporary(position)
    position = transform.position
    return position
end

function Transform.GetLocalPosition(transform, local_position)
    Vector3.SetTemporary(local_position)
    local_position = transform.localPosition
    return local_position
end



function Transform.GetLocalPositionOnce(transform)
    local local_position = Vector3Pool.Get()
    Vector3.SetTemporary(local_position)
    local_position = transform.localPosition
    return local_position
end

function Transform.SetLocalPosition(transform, local_position)
    transform.localPosition = local_position
end

function Transform.SetPosition(transform, position)
    transform.Position = position
end
function Transform.SetLocalPositionXYZ(transform, x, y, z)
    transform:SetLocalPosition(x, y, z)
end

function Transform.SetLocalScaleXYZ(transform, x, y, z)
    transform:SetLocalScale(x, y, z)
end

function Transform.SetPositionXYZ(transform, x, y, z)
    transform:SetPosition(x, y, z)
end

function Transform.GetLocalRotation(transform, localRotation)
    Quaternion.SetTemporary(localRotation)
    localRotation = transform.localRotation
    return localRotation
end

function Transform.GetForward(transform, forward)
    if IsNil(transform) then return forward end

    Vector3.SetTemporary(forward)
    forward = transform.forward
    return forward
end

function Transform.GetForwardOnce(transform)
    local forward = Vector3Pool.Get()
    Vector3.SetTemporary(forward)
    forward = transform.forward
    return forward
end

function Transform.GetRightOnce(transform)
    local right = Vector3Pool.Get()
    Vector3.SetTemporary(right)
    right = transform.right
    return right
end

function Transform.GetUpOnce(transform)
    local up = Vector3Pool.Get()
    Vector3.SetTemporary(up)
    up = transform.up
    return up
end

local mt = {}
mt.__index = function (tbl, key)
    return UnityEngine.Transform[key]
end

setmetatable(Transform, mt)
