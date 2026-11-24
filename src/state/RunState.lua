-- One plain-data run state shared by every scene for the lifetime of Game.
-- The title screen starts a fresh state or restores this saved table; scene
-- changes reuse the same state for the lifetime of the run.

local SaveFile = require("src.state.SaveFile")

local RunState = {}
RunState.MAX_WEEKS = 6

local function defaults()
    return {
        week = 1,
        day = 1, -- Monday-Friday, 6 Saturday, 7 Sunday
        timeOfDay = "AM",
        stats = { int = 1, charm = 1, sense = 1 },
        practice = {
            study = 0,
            hobbies = 0,
            communication = 0,
            emotional_intelligence = 0,
            charisma = 0,
        },
        weekPractice = {
            study = 0,
            hobbies = 0,
            communication = 0,
            emotional_intelligence = 0,
            charisma = 0,
        },
        relationship = { obsession = 75, hate = 0, friendshipness = 25 },
        rewardedLocations = {},
        collection = {},
        nextCollectionCardId = 1,
        latestPack = {},
        packWeek = 0,
    }
end

local function fillMissing(state, fallback)
    for key, value in pairs(fallback) do
        if state[key] == nil then
            state[key] = value
        elseif type(value) == "table" and type(state[key]) == "table" then
            fillMissing(state[key], value)
        end
    end
end

function RunState.new()
    return defaults()
end

function RunState.restore(state)
    if type(state) ~= "table" then
        return defaults()
    end

    fillMissing(state, defaults())
    state.week = math.min(state.week, RunState.MAX_WEEKS)
    return state
end

function RunState.load()
    local saved = SaveFile.load()
    return RunState.restore(saved and saved.runState)
end

return RunState
