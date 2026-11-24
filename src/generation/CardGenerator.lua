-- Genera cartas con valores limitados por las habilidades y un tipo de
-- respuesta ponderado por las actividades practicadas.

local phrases = require("src.data.card_phrases")
local rules = require("src.data.card_rules")

local CardGenerator = {}

-- Identificadores heredados del prototipo: estudio, comunicación efectiva
-- e inteligencia emocional/autoconocimiento, respectivamente.
CardGenerator.STATS = { "int", "charm", "sense" }

local function defaultRandom(...)
    return love.math.random(...)
end

-- Debug tools are intentionally allowed to put RunState into strange states.
-- Treat a negative stat as zero at this boundary, but never "repair" the input
-- table behind the inspector's back: the invalid value should remain visible.
local function effectiveStats(stats)
    assert(type(stats) == "table", "card generation needs a stats table")
    local effective = {}
    for _, name in ipairs(CardGenerator.STATS) do
        local value = stats[name]
        assert(type(value) == "number", name .. " must be a number")
        effective[name] = math.max(0, value)
    end
    return effective
end

function CardGenerator.weights(stats)
    local effective = effectiveStats(stats)
    local weights, total = {}, 0
    for _, name in ipairs(CardGenerator.STATS) do
        weights[name] = effective[name] ^ rules.weightPower
        total = total + weights[name]
    end
    return weights, total, effective
end

-- Imagine each stat as a strip of raffle tickets. A 20/5/10 build owns
-- 20 of the first 35 tickets, then 5, then 10. One roll lands on one strip.
local function weightedPrimary(weights, random, total)
    local target = random() * total
    local cumulative = 0
    for _, name in ipairs(CardGenerator.STATS) do
        cumulative = cumulative + weights[name]
        if target < cumulative then return name end
    end
    return CardGenerator.STATS[#CardGenerator.STATS] -- defensive: random() == 1
end

local function rollValue(hidden, isPrimary, random)
    local low, high
    if isPrimary then
        low, high = math.ceil(hidden * rules.primaryMin), math.floor(hidden)
    else
        low, high = 0, math.floor(hidden * rules.offStatMax)
    end
    if low == high then return low end
    return random(low, high)
end

function CardGenerator.responseChances(emotionalIntelligence, practice, week)
    practice = practice or {}
    local base = (week or 1) <= rules.relationshipShiftWeek
        and rules.earlyResponseWeights or rules.lateResponseWeights
    local perPoint = rules.responseWeightPerPoint
    -- IE starts at one. Training and clinic rewards record each earned point
    -- in both sense and practice, so it contributes to the draw only once.
    local trainedIE = math.max(0, (emotionalIntelligence or 1) - 1,
        practice.emotional_intelligence or 0)
    local communication = math.max(0, practice.communication or 0)
    local study = math.max(0, practice.study or 0)
    local hobbies = math.max(0, practice.hobbies or 0)
    local charisma = math.max(0, practice.charisma or 0)
    local friendship = base.friendship + perPoint * (trainedIE + communication)
    local hate = base.hate + perPoint * study
    local obsession = base.obsession + perPoint * (hobbies + charisma)
    local other = hate + obsession
    local friendshipChance = math.min(rules.maximumFriendshipChance,
        friendship / (friendship + other))
    -- After the cap, hate and obsession still share the rest in proportion.
    return {
        friendship = friendshipChance,
        hate = (1 - friendshipChance) * hate / other,
        obsession = (1 - friendshipChance) * obsession / other,
    }
end

local function chooseResponseType(chances, random)
    local roll = random()
    if roll < chances.friendship then return "friendship" end
    if roll < chances.friendship + chances.hate then return "hate" end
    return "obsession"
end

function CardGenerator.card(stats, random, practice, week, weekPractice)
    random = random or defaultRandom
    local weights, total, effective = CardGenerator.weights(stats)
    assert(total > 0, "cannot generate a card from zero total stats")
    local primary = weightedPrimary(weights, random, total)
    local values = {}

    for _, name in ipairs(CardGenerator.STATS) do
        values[name] = rollValue(effective[name], name == primary, random)
    end

    practice = practice or {}
    local chances = CardGenerator.responseChances(effective.sense, practice, week)
    local responseType = chooseResponseType(chances, random)
    local pool
    if responseType == "obsession" then
        local weeklyCharisma = (weekPractice or practice).charisma or 0
        local complimentChance = math.min(rules.maximumComplimentChance,
            math.max(0, weeklyCharisma) * rules.complimentPerCharismaPractice)
        pool = random() < complimentChance and phrases.charisma or phrases.obsession
    else
        pool = phrases[responseType]
    end
    assert(pool, "missing response phrase pool: " .. responseType)
    return {
        primary = primary,
        phrase = pool[random(1, #pool)],
        responseType = responseType,
        stats = values,
    }
end

function CardGenerator.pack(stats, count, random, practice, week, weekPractice)
    count = count or 5
    assert(count >= 0 and count == math.floor(count),
        "pack size must be a non-negative integer")
    local cards = {}
    for i = 1, count do
        cards[i] = CardGenerator.card(stats, random, practice, week, weekPractice)
    end
    return cards
end

return CardGenerator
