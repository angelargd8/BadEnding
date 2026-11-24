-- Final outcome after the sixth Sunday summary.

local Scene = require("src.ecs.Scene")
local EndingInputSystem = require("src.systems.EndingInputSystem")
local EndingRenderSystem = require("src.systems.EndingRenderSystem")

return function(payload)
    payload = payload or {}
    local scene = Scene.new("ending")
    scene.registry:setResource("ending", { result = payload.result })
    scene:addSystem(EndingInputSystem)
    scene:addSystem(EndingRenderSystem)
    return scene
end
