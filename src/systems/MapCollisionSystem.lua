-- Keeps the map actor inside the playable area and resolves overlap with
-- static solid rectangles. MovementSystem remains generic; this system
-- owns only the map's blocking rules.

local Screen = require("src.Screen")

local MapCollisionSystem = { name = "mapCollision" }

local function clamp(value, low, high)
    return math.max(low, math.min(value, high))
end

local function overlaps(a, b)
    return a.x < b.x + b.w and a.x + a.w > b.x
        and a.y < b.y + b.h and a.y + a.h > b.y
end

local function collides(rect, obstacles)
    for _, obstacle in ipairs(obstacles) do
        if overlaps(rect, obstacle) then return true end
    end
    return false
end

local function bodyRect(pos, body)
    return {
        x = pos.x + (body.x or 0),
        y = pos.y + (body.y or 0),
        w = body.w,
        h = body.h,
    }
end

function MapCollisionSystem.update(scene, dt)
    local registry = scene.registry
    local obstacles = {}

    for _, pos, solid in registry:each("position", "solid") do
        obstacles[#obstacles + 1] = {
            x = pos.x + solid.x,
            y = pos.y + solid.y,
            w = solid.w,
            h = solid.h,
        }
    end

    for _, pos, velocity, body, sprite in
        registry:each("position", "velocity", "body", "sprite") do

        local maxX = math.max(0, Screen.w - sprite.w * (sprite.scale or 1))
        local maxY = math.max(0, Screen.h - sprite.h * (sprite.scale or 1))
        local dx, dy = velocity.x * dt, velocity.y * dt
        local oldX = clamp(pos.x - dx, 0, maxX)
        local oldY = clamp(pos.y - dy, 0, maxY)

        -- Keep a known-free position so a tiny overlap or rounding error
        -- cannot leave the actor stuck inside a prop on the next frame.
        if body.safeX == nil then
            body.safeX, body.safeY = oldX, oldY
        elseif collides(bodyRect({ x = oldX, y = oldY }, body), obstacles) then
            oldX = clamp(body.safeX, 0, maxX)
            oldY = clamp(body.safeY, 0, maxY)
        end

        local nextX = clamp(oldX + dx, 0, maxX)
        local nextY = clamp(oldY + dy, 0, maxY)

        -- Resolve each axis separately so the player can slide along a wall.
        pos.x, pos.y = nextX, oldY
        if collides(bodyRect(pos, body), obstacles) then
            pos.x = oldX
        end

        pos.y = nextY
        if collides(bodyRect(pos, body), obstacles) then
            pos.y = oldY
        end

        if collides(bodyRect(pos, body), obstacles) then
            pos.x, pos.y = body.safeX, body.safeY
        else
            body.safeX, body.safeY = pos.x, pos.y
        end
    end
end

return MapCollisionSystem
