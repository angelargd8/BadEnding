package.path = "./?.lua;" .. package.path

local CardGenerator = require("src.generation.CardGenerator")
local HandGenerator = require("src.generation.HandGenerator")
local rules = require("src.data.card_rules")

-- Tiny deterministic RNG for tests: reproducible without opening a LÖVE window.
local function seededRandom(seed)
    return function(low, high)
        seed = (1103515245 * seed + 12345) % 2147483648
        local unit = seed / 2147483648
        if low == nil then return unit end
        if high == nil then return math.floor(unit * low) + 1 end
        return low + math.floor(unit * (high - low + 1))
    end
end

local function assertCardBounds(card, hidden)
    for _, name in ipairs(CardGenerator.STATS) do
        local value = card.stats[name]
        assert(value >= 0 and value <= hidden[name], name .. " escaped its ceiling")
        if name == card.primary then
            assert(value >= math.ceil(hidden[name] * rules.primaryMin),
                name .. " missed its primary floor")
        else
            assert(value <= math.floor(hidden[name] * rules.offStatMax),
                name .. " escaped its off-stat ceiling")
        end
    end
end

local hidden = { int = 20, charm = 5, sense = 10 }
local random = seededRandom(3096)
local counts = { int = 0, charm = 0, sense = 0 }
local sampleSize = 10000

for _ = 1, sampleSize do
    local card = CardGenerator.card(hidden, random)
    assertCardBounds(card, hidden)
    counts[card.primary] = counts[card.primary] + 1
end

local weights, total = CardGenerator.weights(hidden)
for _, name in ipairs(CardGenerator.STATS) do
    local observed = counts[name] / sampleSize
    local expected = weights[name] / total
    assert(math.abs(observed - expected) < 0.02,
        ("%s distribution drifted: %.3f vs %.3f"):format(
            name, observed, expected))
end

local function checkResponseChances(week, sense, practice, friendship, hate, obsession)
    local actual = CardGenerator.responseChances(sense, practice, week)
    local expected = { friendship = friendship, hate = hate, obsession = obsession }
    for kind, chance in pairs(expected) do
        assert(math.abs(actual[kind] - chance) < 1e-9,
            ("week %d, %s: expected %.4f, got %.4f"):format(
                week, kind, chance, actual[kind]))
    end
end

checkResponseChances(1, 1, {}, .45, .40, .15)
checkResponseChances(3, 1, {}, .45, .40, .15)
checkResponseChances(4, 1, {}, .14, .23, .63)
-- The first earned IE point must help even after weekly practice resets.
checkResponseChances(1, 2, {}, 49/104, 40/104, 15/104)
checkResponseChances(1, 2, { emotional_intelligence = 1 }, 49/104, 40/104, 15/104)
checkResponseChances(3, 1, { study = 5 }, 45/120, 60/120, 15/120)
checkResponseChances(6, 1, { hobbies = 2, charisma = 3 }, 14/120, 23/120, 83/120)
checkResponseChances(6, 1, { communication = 1 }, 18/104, 23/104, 63/104)
checkResponseChances(6, 300, { study = 5 }, .60, .40 * 43/106, .40 * 63/106)

local collection = {}
for i = 1, 12 do collection[i] = { id = i } end
local hand = HandGenerator.draw(collection, 5, seededRandom(96))
local seen = {}
for _, card in ipairs(hand) do
    assert(not seen[card.id], "a hand drew the same card twice")
    seen[card.id] = true
end
assert(#collection == 12, "drawing a hand mutated the collection")

-- The debug inspector may temporarily push a stat below zero. Generation and
-- weight display clamp it at their boundary without hiding the bad source data.
local debugStats = { int = -12, charm = 4, sense = -2 }
local safeWeights, safeTotal = CardGenerator.weights(debugStats)
assert(safeWeights.int == 0 and safeWeights.charm == 4
    and safeWeights.sense == 0 and safeTotal == 4,
    "negative debug stats were not treated as zero")
local safeCard = CardGenerator.card(debugStats, seededRandom(5))
assert(safeCard.primary == "charm" and safeCard.stats.int == 0
    and safeCard.stats.sense == 0,
    "a negative debug stat leaked into a generated card")
assert(debugStats.int == -12 and debugStats.sense == -2,
    "generation silently mutated the inspected RunState")

local ok = pcall(CardGenerator.card,
    { int = 0, charm = 0, sense = 0 }, seededRandom(1))
assert(not ok, "zero-total stats should fail loudly")

print(("generation tests passed -- I:%d C:%d S:%d"):format(
    counts.int, counts.charm, counts.sense))
