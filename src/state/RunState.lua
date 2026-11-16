-- One plain-data run state shared by every scene for the lifetime of Game.
-- Disk loading happens once at startup; scene changes reuse this same table.

local SaveFile = require("src.state.SaveFile")

local RunState = {}
RunState.MAX_WEEKS = 6

local function defaults()
    return {
        week = 1,
        day = 1, -- 1..5 Monday-Friday, 6 Saturday morning
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
        relationship = { obsession = 0, hate = 0, friendshipness = 0 },
        collection = {},
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

function RunState.load()
    local saved = SaveFile.load()
    local state = saved and saved.runState

    if type(state) ~= "table" then
        return defaults()
    end

    fillMissing(state, defaults())
    state.week = math.min(state.week, RunState.MAX_WEEKS)
    return state
end

return RunState
