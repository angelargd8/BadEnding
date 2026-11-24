-- Saves Sunday's results and starts the next week on request.

local RunState = require("src.state.RunState")
local SaveFile = require("src.state.SaveFile")
local EndingRules = require("src.state.EndingRules")

local SundaySummaryInputSystem = { name = "sundaySummaryInput" }

function SundaySummaryInputSystem.setup(scene)
    SaveFile.save({
        runState = scene.registry:resource("runState"),
        scene = "sundaySummary",
    })
end

local function requestedAdvance(registry)
    for _, key in registry:each("keyPressed") do
        if key.key == "space" or key.key == "return" then return true end
    end
    for _, mouse in registry:each("mousePressed") do
        if mouse.button == 1 then return true end
    end
    return false
end

function SundaySummaryInputSystem.update(scene)
    local registry = scene.registry
    if not requestedAdvance(registry) then return end

    local runState = registry:resource("runState")
    if runState.week >= RunState.MAX_WEEKS then
        local result = EndingRules.evaluate(runState)
        SaveFile.save({
            runState = runState,
            scene = "ending",
            payload = { result = result },
        })
        registry:spawn({
            switchRequest = {
                to = "ending",
                payload = { result = result },
            },
        })
        return
    end

    runState.week = runState.week + 1
    runState.day = 1
    runState.timeOfDay = "AM"
    runState.weekPractice = {
        study = 0,
        hobbies = 0,
        communication = 0,
        emotional_intelligence = 0,
        charisma = 0,
    }
    SaveFile.save({ runState = runState, scene = "week" })
    registry:spawn({ switchRequest = { to = "week" } })
end

return SundaySummaryInputSystem
