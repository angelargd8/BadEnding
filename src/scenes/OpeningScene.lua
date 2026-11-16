-- Opening narration before the weekly activity loop.

local Scene = require("src.ecs.Scene")
local OpeningTextSystem = require("src.systems.OpeningTextSystem")

return function(payload)
    local scene = Scene.new("opening")
    scene:addSystem(OpeningTextSystem)
    return scene
end
