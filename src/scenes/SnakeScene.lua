-- A compact arcade scene opened by stepping onto the sofa at home.

local Scene = require("src.ecs.Scene")
local SnakeInputSystem = require("src.systems.SnakeInputSystem")
local SnakeSystem = require("src.systems.SnakeSystem")
local SnakeRenderSystem = require("src.systems.SnakeRenderSystem")

return function(payload)
    payload = payload or {}
    local scene = Scene.new("snake")
    if payload.snake then
        scene.registry:setResource("snake", payload.snake)
    end
    scene:addSystem(SnakeInputSystem)
    scene:addSystem(SnakeSystem)
    scene:addSystem(SnakeRenderSystem)
    return scene
end
