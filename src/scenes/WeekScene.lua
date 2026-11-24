-- Escena semanal de Bad Ending. El protagonista elige cómo ocupar su
-- tiempo durante las seis semanas antes de graduarse.

local Scene = require("src.ecs.Scene")

local MenuInputSystem = require("src.systems.MenuInputSystem")
local StatsSystem = require("src.systems.StatsSystem")
local VignetteSystem = require("src.systems.VignetteSystem")
local DayLoopSystem = require("src.systems.DayLoopSystem")
local TextboxSystem = require("src.systems.TextboxSystem")
local MenuRenderSystem = require("src.systems.MenuRenderSystem")
local TextboxRenderSystem = require("src.systems.TextboxRenderSystem")
local DateRenderSystem = require("src.systems.DateRenderSystem")
local RadarRenderSystem = require("src.systems.RadarRenderSystem")
local ProtagonistRenderSystem = require("src.systems.ProtagonistRenderSystem")
local FadeRenderSystem = require("src.systems.FadeRenderSystem")

return function(payload)
    local scene = Scene.new("week")
    payload = payload or {}
    local savedDayloop = payload.dayloop or {}

    -- The runState is injected by Game and survives scene changes. The
    -- day-loop phase is local to this scene and can be restored from a save.
    scene.registry:setResource("dayloop", {
        phase = savedDayloop.phase or "choosing",
        timer = savedDayloop.timer or 0,
        flipped = savedDayloop.flipped or false,
    })

    -- the activity menu: one entity, pure data
    scene.registry:spawn({
        position = { x = 324, y = 96 },
        menu = {
            options = { "study", "hobbies", "communication",
                "emotional_intelligence", "charisma" },
            cursor  = payload.menuCursor or 1,
            spacing = 62, -- horizontal distance between icon origins
        },
    })

    -- the text box: the bottom strip. Pure output — the vignette and
    -- the day loop write into it, the typewriter does the rest.
    scene.registry:spawn({
        position = { x = 12, y = 316 },
        size = { w = 616, h = 72 },
        textbox = {
            text = (payload.textbox and payload.textbox.text) or "¿Qué harás hoy?",
            visibleChars = (payload.textbox and payload.textbox.visibleChars) or 0,
            speed = 40, -- characters per second
        },
    })

    -- input first, then the three reactions to activityPicked, then
    -- presentation — fade LAST, it paints over everyone
    scene:addSystem(MenuInputSystem)
    scene:addSystem(StatsSystem)
    scene:addSystem(VignetteSystem)
    scene:addSystem(DayLoopSystem)
    scene:addSystem(TextboxSystem)
    scene:addSystem(MenuRenderSystem)
    scene:addSystem(ProtagonistRenderSystem)
    scene:addSystem(TextboxRenderSystem)
    scene:addSystem(DateRenderSystem)
    scene:addSystem(RadarRenderSystem)
    scene:addSystem(FadeRenderSystem)

    return scene
end
