local math = math
local living_cache = {}
local die_cache = {}

u3dpool = u3dpool or {}
function u3dpool.__alloc(_x, _y, _z)
    local t = next(die_cache)
    if nil ~= t then
        die_cache[t] = nil
        t.x = _x
        t.y = _y
        t.z = _z
    else
        t = {x = _x, y = _y, z = _z}
    end

    living_cache[t] = t
    return t
end

function u3dpool.Update(now_time, elapse_time)
    for k,v in pairs(living_cache) do
        die_cache[k] = v
        living_cache[k] = nil
    end
end

function u3dpool.reset(data)
    data.x = 0
    data.y = 0
    data.z = 0
end

function u3dpool.set(data, _x, _y, _z)
    data.x = _x
    data.y = _y
    data.z = _z
end

function u3dpool.release2pool(data)
    if nil ~= living_cache[data] then
        die_cache[data] = data
        living_cache[data] = nil

        data.x = 0
        data.y = 0
        data.z = 0
    end
end

function u3dpool.vec2(_x, _y, not_pool)
    if not_pool then
        return {x = _x, y = _y, z = 0.0}
    else
        return u3dpool.__alloc(_x, _y, 0.0)
    end
end

-- 加
function u3dpool.v2Add(v2a, v2b, dest)
    if nil ~= dest then
        u3dpool.set(dest, v2a.x + v2b.x, v2a.y + v2b.y)
        return dest
    else
        return u3dpool.__alloc(v2a.x + v2b.x, v2a.y + v2b.y)
    end
end

-- 减
function u3dpool.v2Sub(v2a, v2b, dest)
    if nil ~= dest then
        u3dpool.set(dest, v2a.x - v2b.x, v2a.y - v2b.y)
        return dest
    else
        return u3dpool.__alloc(v2a.x - v2b.x, v2a.y - v2b.y)
    end
end

-- 乘一个数
function u3dpool.v2Mul(v2a, factor, dest)
    if nil ~= dest then
        u3dpool.set(dest, v2a.x * factor, v2a.y * factor)
        return dest
    else
        return u3dpool.__alloc(v2a.x * factor, v2a.y * factor)
    end
end

-- 中点
function u3dpool.v2Mid(v2a, v2b)
    return u3dpool.__alloc((v2a.x + v2b.x) / 2.0, ( v2a.y + v2b.y) / 2.0)
end

-- 角度转向量
function u3dpool.v2ForAngle(a)
    return u3dpool.__alloc(math.cos(a), math.sin(a))
end

-- 向量转角度
function u3dpool.v2Angle(v2)
    return math.atan2(v2.y, v2.x)
end

-- 长度
function u3dpool.v2Length(v2, is_sqrt)
    if is_sqrt ~= false then
        return math.sqrt(v2.x * v2.x + v2.y * v2.y)
    end
    return v2.x * v2.x + v2.y * v2.y
end

-- 单位化
function u3dpool.v2Normalize(v2, dest)
    local length = u3dpool.v2Length(v2)
    local x = 1
    local y = 0
    if 0 ~= length then
        x = v2.x / length
        y = v2.y / length
    end

    if nil ~= dest then
        u3dpool.set(dest, x, y)
        return dest
    end

    return u3dpool.__alloc(x, y)
end

-- 二维向量旋转a度（-1向左旋转，1向右旋转）
function u3dpool.v2Rotate(v2, a, dir)
    dir = dir or 1
    if dir ^ 2 == 1 then
        return u3dpool.__alloc(v2.x * math.cos(math.rad(a * dir)) + v2.y * math.sin(math.rad(a * dir)),
                -v2.x * math.sin(math.rad(a * dir)) + v2.y * math.cos(math.rad(a * dir)))
    else
        return u3dpool.__alloc(v2.x, v2.y)
    end
end

function u3dpool.vec3(_x, _y, _z)
    return u3dpool.__alloc(_x, _y, _z)
end

function u3dpool.v3Add(v3a, v3b)
    return u3dpool.__alloc(v3a.x + v3b.x, v3a.y + v3b.y, v3a.z + v3b.z)
end

function u3dpool.v3Sub(v3a, v3b)
    return u3dpool.__alloc(v3a.x - v3b.x, v3a.y - v3b.y, v3a.z - v3b.z)
end

function u3dpool.v3Length(v3, is_sqrt)
    if is_sqrt ~= false then
        return math.sqrt(v3.x * v3.x + v3.y * v3.y + v3.z * v3.z)
    end
    return v3.x * v3.x + v3.y * v3.y + v3.z * v3.z
end

function u3dpool.v3Normalize(v3)
    local length = u3dpool.v3Length(v3)
    if 0 == length then
        return u3dpool.__alloc(0, 0, 1)
    end

    return u3dpool.__alloc(v3.x / length, v3.y / length, v3.z / length)
end

function u3dpool.v3Mul(v3, factor)
    return u3dpool.__alloc(v3.x * factor, v3.y * factor, v3.z * factor)
end

function u3dpool.v3Dot(v3a, v3b)
    return v3a.x * v3b.x + v3a.y * v3b.y + v3a.z * v3b.z
end

function u3dpool.v3Cross(v1, v2)
    local v3 ={x = v1.y*v2.z - v2.y*v1.z , y = v2.x*v1.z-v1.x*v2.z , z = v1.x*v2.y-v2.x*v1.y}
    return v3
end

function u3dpool.GetVector3Module(v)
    return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
end

function u3dpool.GetVector3Angle(v1, v2)
    local cos = u3dpool.v3Dot(v1, v2)/ (u3dpool.GetVector3Module(v1)*u3dpool.GetVector3Module(v2))
    return math.acos(cos) * 180 / math.pi
end

-- for i=1,10000 do
-- 	local t = {x = 0, y = 0, z = 0}
-- 	die_cache[t] = t
-- 	-- u3dpool.__alloc(0, 0, 0)
-- end