-- Saturday morning: reveal the five cards earned from this week's progress.

local Scene = require("src.ecs.Scene")
local PackOpeningInputSystem = require("src.systems.PackOpeningInputSystem")
local PackOpeningSystem = require("src.systems.PackOpeningSystem")
local PackOpeningRenderSystem = require("src.systems.PackOpeningRenderSystem")

return function(payload)
    local scene = Scene.new("packOpening")
    scene.registry:setResource("packOpening", {
        selected = 1,
        cards = {},
        ready = false,
    })

    scene:addSystem(PackOpeningInputSystem)
    scene:addSystem(PackOpeningSystem)
    scene:addSystem(PackOpeningRenderSystem)

    return scene
end
