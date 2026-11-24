-- Evaluates the relationship and activity requirements for the final ending.

local Relationship = require("src.state.Relationship")

local EndingRules = {
    MIN_STUDY_PERCENT = 30,
    MIN_HAPPINESS_PERCENT = 30,
}

local ACTIVITY_KEYS = {
    "study",
    "hobbies",
    "communication",
    "emotional_intelligence",
    "charisma",
}

local function count(value)
    return math.max(0, tonumber(value) or 0)
end

function EndingRules.activityRates(runState)
    local practice = runState.practice or {}
    local stats = runState.stats or {}
    local counts = {}
    local total = 0

    for _, key in ipairs(ACTIVITY_KEYS) do
        counts[key] = count(practice[key])
        total = total + counts[key]
    end

    if total == 0 then
        return {
            study = math.max(0, math.min(100, count(stats.int))),
            happiness = 0,
            total = 0,
        }
    end

    return {
        -- The study bar uses the same INT score shown in the summary card:
        -- one study point equals one percent, capped at 100%.
        study = math.max(0, math.min(100, count(stats.int))),
        happiness = counts.hobbies / total * 100,
        total = total,
    }
end

function EndingRules.evaluate(runState)
    local activity = EndingRules.activityRates(runState)
    local relationship = Relationship.finalOutcome(runState)
    local studyMet = activity.study > EndingRules.MIN_STUDY_PERCENT
    local happinessMet = activity.happiness > EndingRules.MIN_HAPPINESS_PERCENT

    return {
        relationship = relationship,
        studyPercent = activity.study,
        happinessPercent = activity.happiness,
        studyMet = studyMet,
        happinessMet = happinessMet,
        won = relationship == "friends" and studyMet and happinessMet,
    }
end

return EndingRules
