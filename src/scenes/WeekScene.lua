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
local FadeRenderSystem = require("src.systems.FadeRenderSystem")

return function(payload)
    local scene = Scene.new("week")

    -- The runState is injected by Game and survives scene changes. The
    -- day-loop phase is local to this scene and starts fresh on each visit.
    scene.registry:setResource("dayloop", {
        phase = "choosing", -- choosing -> vignette -> fade -> choosing
        timer = 0,
        flipped = false, -- has this fade already advanced the day?
    })

    -- the activity menu: one entity, pure data
    scene.registry:spawn({
        position = { x = 324, y = 96 },
        menu = {
            options = { "study", "hobbies", "communication",
                "emotional_intelligence", "charisma" },
            cursor  = 1,
            spacing = 62, -- horizontal distance between icon origins
        },
    })

    -- the text box: the bottom strip. Pure output — the vignette and
    -- the day loop write into it, the typewriter does the rest.
    scene.registry:spawn({
        position = { x = 12, y = 316 },
        size = { w = 616, h = 72 },
        textbox = {
            text = "¿Qué harás hoy?",
            visibleChars = 0,
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
    scene:addSystem(TextboxRenderSystem)
    scene:addSystem(DateRenderSystem)
    scene:addSystem(RadarRenderSystem)
    scene:addSystem(FadeRenderSystem)

    return scene
end
