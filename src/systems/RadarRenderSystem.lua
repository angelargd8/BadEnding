-- Shows study, happiness and emotional intelligence on the weekly radar.

local RadarRenderSystem = { name = "radarRender" }
local palette = require("src.data.menu_palette")

local CX, CY = 76, 250 -- center: left column, riding above the text box
local R = 44 -- radius to a corner, px

-- Scores keep accumulating after the displayed axis reaches the rim.
local DISPLAY_MAX = 30

local AXES = {
    { source = "stats", key = "int", label = "E", angle = -math.pi / 2 },
    { source = "practice", key = "hobbies", label = "Felicidad", angle = 5 * math.pi / 6 },
    { source = "stats", key = "sense", label = "IE", angle = math.pi / 6 },
}

-- A small five-point outline also works with fonts that have no star glyph.
local HAPPINESS_STAR = {
    0, -5,  1.5, -1.5,  5, -1.5,  2.5, 1,  3, 4.5,
    0, 2.5,  -3, 4.5,  -2.5, 1,  -5, -1.5,  -1.5, -1.5,
}

local labelFont

function RadarRenderSystem.setup(scene)
    labelFont = love.graphics.newFont(11)
end

function RadarRenderSystem.unload(scene)
    -- drop the reference, the GC collects it; never release() fonts
    labelFont = nil
end

-- corner of the triangle at `fraction` of the way out along an axis
local function point(axis, fraction)
    return CX + math.cos(axis.angle) * R * fraction,
        CY + math.sin(axis.angle) * R * fraction
end

function RadarRenderSystem.draw(scene)
    local runState = scene.registry:resource("runState")
    local frame, shape = {}, {}
    local activeAxes, tipX, tipY = 0, CX, CY

    love.graphics.setColor(0, 0, 0, 0.35)
    for _, axis in ipairs(AXES) do
        local x, y = point(axis, 1)
        frame[#frame + 1] = x
        frame[#frame + 1] = y
        love.graphics.line(CX, CY, x, y)

        local source = runState[axis.source]
        local score = math.max(0, source and source[axis.key] or 0)
        x, y = point(axis, math.min(score / DISPLAY_MAX, 1))
        shape[#shape + 1] = x
        shape[#shape + 1] = y
        if score > 0 then
            activeAxes = activeAxes + 1
            tipX, tipY = x, y
        end
    end
    love.graphics.polygon("line", frame)

    if activeAxes >= 2 then
        love.graphics.setColor(0.70, 0.22, 0.31, 0.22)
        love.graphics.polygon("fill", shape)
        love.graphics.setColor(palette.red)
        love.graphics.polygon("line", shape)
    elseif activeAxes == 1 then
        love.graphics.setColor(palette.red)
        love.graphics.line(CX, CY, tipX, tipY)
    end

    love.graphics.setColor(palette.black)
    love.graphics.setFont(labelFont)
    for _, axis in ipairs(AXES) do
        local x, y = point(axis, 1.25)
        if axis.key == "hobbies" then
            love.graphics.push("all")
            love.graphics.translate(x, y)
            love.graphics.setColor(palette.rose)
            love.graphics.polygon("line", HAPPINESS_STAR)
            love.graphics.pop()
            y = y + labelFont:getHeight()
        end
        local labelX = math.max(4, x - labelFont:getWidth(axis.label) / 2)
        love.graphics.print(axis.label, labelX, y - labelFont:getHeight() / 2)
    end
    love.graphics.setColor(palette.black)
end

return RadarRenderSystem
