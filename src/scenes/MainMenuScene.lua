-- The title screen and entry point for a new or saved story.

local Scene = require("src.ecs.Scene")
local SaveFile = require("src.state.SaveFile")
local MainMenuInputSystem = require("src.systems.MainMenuInputSystem")
local MainMenuRenderSystem = require("src.systems.MainMenuRenderSystem")

return function()
    local scene = Scene.new("mainMenu")
    local saved = SaveFile.load()
    scene.registry:setResource("mainMenu", {
        selected = 1,
        canLoad = type(saved) == "table" and type(saved.runState) == "table",
        options = {
            { label = "Start", action = "start", y = 190 },
            { label = "Load Game", action = "load", y = 234 },
            { label = "Quit", action = "quit", y = 278 },
        },
    })
    scene:addSystem(MainMenuInputSystem)
    scene:addSystem(MainMenuRenderSystem)
    return scene
end
