-- Escena semanal de Bad Ending. El protagonista elige cómo ocupar su
-- tiempo durante las doce semanas antes de graduarse.

local Scene = require("src.ecs.Scene")
local SaveFile = require("src.state.SaveFile")

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

    -- RUN state: the one table every scene of the game reads and
    -- writes (GDD §10) — and the thing the save file persists. Loaded
    -- fresh from disk every time the scene is built; defaults are what
    -- week 1, Monday morning looks like. (Saving it back is the recap
    -- lesson's job.)
    local data = SaveFile.load()
    local runState = data and data.runState
    if runState then
        runState.practice = runState.practice or {
            study = 0, hobbies = 0, communication = 0,
            emotional_intelligence = 0, charisma = 0,
        }
        for _, key in ipairs({ "study", "hobbies", "communication",
            "emotional_intelligence", "charisma" }) do
            runState.practice[key] = runState.practice[key] or 0
        end
        -- Compatibilidad con partidas creadas antes de añadir los tres
        -- estados de relación definidos en el GDD.
        runState.relationship = runState.relationship or {
            obsession = 0, hate = 0, friendshipness = 0,
        }
    end
    scene.registry:setResource("runState",
        runState or {
            week = 1,
            day = 1, -- 1..5, Mon-Fri
            -- La base no nula permite generar cartas con pesos definidos.
            stats = { int = 1, charm = 1, sense = 1 },
            practice = {
                study = 0, hobbies = 0, communication = 0,
                emotional_intelligence = 0, charisma = 0,
            },
            relationship = { obsession = 0, hate = 0, friendshipness = 0 },
            collection = {},
        })

    -- SCENE state, by contrast: the day loop's phase machine lives and
    -- dies with the scene and is never saved. Compare with runState
    -- above — that split is the whole lesson-05 distinction, in code.
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
