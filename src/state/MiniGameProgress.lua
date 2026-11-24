-- Adds bonus activity points when a mini-game run reaches a terminal result.

local MiniGameProgress = {}
local POINTS_PER_MINI_GAME = 5
local STAT_BY_ACTIVITY = {
    study = "int",
    emotional_intelligence = "sense",
    -- Hobbies are tracked as happiness through practice counts.
}

function MiniGameProgress.grant(runState, gameState, activityKey)
    if type(runState) ~= "table" or type(gameState) ~= "table"
            or gameState.progressGranted then
        return false
    end

    if activityKey ~= "study" and activityKey ~= "hobbies"
            and activityKey ~= "emotional_intelligence" then
        return false
    end

    runState.stats = runState.stats or {}
    runState.practice = runState.practice or {}
    runState.weekPractice = runState.weekPractice or {}

    local stat = STAT_BY_ACTIVITY[activityKey]
    if stat then
        runState.stats[stat] = (tonumber(runState.stats[stat]) or 0)
            + POINTS_PER_MINI_GAME
    end
    runState.practice[activityKey] =
        (tonumber(runState.practice[activityKey]) or 0) + POINTS_PER_MINI_GAME
    runState.weekPractice[activityKey] =
        (tonumber(runState.weekPractice[activityKey]) or 0)
            + POINTS_PER_MINI_GAME

    gameState.progressGranted = true
    return true
end

return MiniGameProgress
