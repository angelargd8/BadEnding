-- Opening narration before the weekly activity loop.

local Scene = require("src.ecs.Scene")
local OpeningTextSystem = require("src.systems.OpeningTextSystem")

return function(payload)
    payload = payload or {}
    local scene = Scene.new("opening")
    scene.registry:setResource("opening", { page = payload.page or 1 })
    scene:addSystem(OpeningTextSystem)
    return scene
end
