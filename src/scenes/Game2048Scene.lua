-- A keyboard-controlled 2048 mini-game opened by the books in the school.

local Scene = require("src.ecs.Scene")
local Game2048InputSystem = require("src.systems.Game2048InputSystem")
local Game2048System = require("src.systems.Game2048System")
local Game2048RenderSystem = require("src.systems.Game2048RenderSystem")

return function(payload)
    payload = payload or {}
    local scene = Scene.new("game2048")
    if payload.game2048 then
        scene.registry:setResource("game2048", payload.game2048)
    end
    scene:addSystem(Game2048InputSystem)
    scene:addSystem(Game2048System)
    scene:addSystem(Game2048RenderSystem)
    return scene
end
