-- A square-only Flappy Bird mini-game opened from the clinic table.

local Scene = require("src.ecs.Scene")
local FlappyBirdInputSystem = require("src.systems.FlappyBirdInputSystem")
local FlappyBirdSystem = require("src.systems.FlappyBirdSystem")
local FlappyBirdRenderSystem = require("src.systems.FlappyBirdRenderSystem")

return function(payload)
    payload = payload or {}
    local scene = Scene.new("flappyBird")
    if payload.flappyBird then
        scene.registry:setResource("flappyBird", payload.flappyBird)
    end
    scene:addSystem(FlappyBirdInputSystem)
    scene:addSystem(FlappyBirdSystem)
    scene:addSystem(FlappyBirdRenderSystem)
    return scene
end
