-- Lets the player select and shuffle five collection cards before the date.

local Scene = require("src.ecs.Scene")
local DeckBuilderInputSystem = require("src.systems.DeckBuilderInputSystem")
local DeckBuilderRenderSystem = require("src.systems.DeckBuilderRenderSystem")

return function(payload)
    payload = payload or {}
    local scene = Scene.new("deckBuilder")
    if payload.deckBuilder then
        scene.registry:setResource("deckBuilder", payload.deckBuilder)
    end
    scene:addSystem(DeckBuilderInputSystem)
    scene:addSystem(DeckBuilderRenderSystem)
    return scene
end
