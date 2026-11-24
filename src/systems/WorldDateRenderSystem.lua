-- Displays the shared calendar date while walking through the world.

local WorldDateRenderSystem = { name = "worldDateRender" }
local DAY_NAMES = {
    "LUNES", "MARTES", "MIÉRCOLES", "JUEVES", "VIERNES",
    "SÁBADO", "DOMINGO",
}

function WorldDateRenderSystem.draw(scene)
    local runState = scene.registry:resource("runState")
    if not runState then return end

    love.graphics.setColor(0.055, 0.065, 0.105, 0.86)
    love.graphics.rectangle("fill", 12, 12, 178, 48, 5, 5)
    love.graphics.setColor(0.94, 0.89, 0.76, 1)
    love.graphics.printf(("%s · %s"):format(
        DAY_NAMES[runState.day] or "DÍA", runState.timeOfDay or "AM"),
        20, 18, 162, "left")
    love.graphics.setColor(1, 1, 1, 0.72)
    love.graphics.printf(("SEMANA %d"):format(runState.week),
        20, 38, 162, "left")
    love.graphics.setColor(1, 1, 1, 1)
end

return WorldDateRenderSystem
