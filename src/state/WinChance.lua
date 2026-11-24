-- Calculates the positive-outcome chance for Saturday dates.

local WinChance = {}

local function bounded(value)
    return math.max(5, math.min(95, value))
end

function WinChance.date(runState, battle)
    runState = runState or {}
    battle = battle or {}
    local counts = { friendship = 0, hate = 0, obsession = 0 }
    -- Before the first response, estimate from the five-card deck. Once the
    -- date begins, use only the cards the player actually chose to play.
    local cards = battle.history and #battle.history > 0
        and battle.history or battle.hand or {}
    for _, card in ipairs(cards) do
        if counts[card.responseType] ~= nil then
            counts[card.responseType] = counts[card.responseType] + 1
        end
    end

    local practice = runState.practice or {}
    local communication = math.max(0, practice.communication or 0)
    local emotionalIntelligence = math.max(0,
        practice.emotional_intelligence or 0)
    local skillBonus = math.min(18,
        (communication + emotionalIntelligence) * 1.5)

    return math.floor(bounded(35 + counts.friendship * 10
        - counts.hate * 7 - counts.obsession * 3 + skillBonus) + 0.5)
end

function WinChance.roll(chance)
    return love.math.random(1, 100) <= chance
end

return WinChance
