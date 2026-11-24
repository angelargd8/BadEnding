-- Sunday's statistics screen before the next week begins.

local Scene = require("src.ecs.Scene")
local SundaySummaryInputSystem = require("src.systems.SundaySummaryInputSystem")
local SundaySummaryRenderSystem = require("src.systems.SundaySummaryRenderSystem")

return function(payload)
    local scene = Scene.new("sundaySummary")
    scene:addSystem(SundaySummaryInputSystem)
    scene:addSystem(SundaySummaryRenderSystem)
    return scene
end
