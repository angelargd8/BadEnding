-- Generates and stores one five-card pack for each completed week.

local CardGenerator = require("src.generation.CardGenerator")
local rules = require("src.data.card_rules")
local RunState = require("src.state.RunState")

local PackOpeningSystem = { name = "packOpening" }

function PackOpeningSystem.setup(scene)
    local runState = scene.registry:resource("runState")
    local opening = scene.registry:resource("packOpening")

    if runState.day == 6 and runState.packWeek ~= runState.week then
        local seed = love.math.random(1, 2147483646)
        local rng = love.math.newRandomGenerator(seed)
        local pack = CardGenerator.pack(
            runState.stats,
            rules.packSize,
            function(...) return rng:random(...) end,
            runState.weekPractice
        )

        runState.packWeek = runState.week
        runState.latestPack = pack
        for _, card in ipairs(pack) do
            runState.collection[#runState.collection + 1] = card
        end
    end

    if runState.packWeek == runState.week then
        opening.cards = runState.latestPack
    end
    local hasPack = runState.day == 6
        and #opening.cards == rules.packSize
    opening.finished = hasPack and runState.week >= RunState.MAX_WEEKS
    opening.ready = hasPack and not opening.finished
end

function PackOpeningSystem.update(scene, dt)
    local registry = scene.registry
    local runState = registry:resource("runState")
    local opening = registry:resource("packOpening")

    for _ in registry:each("packContinueRequested") do
        if opening.ready and runState.day == 6
                and runState.week < RunState.MAX_WEEKS then
            runState.week = runState.week + 1
            runState.day = 1
            runState.weekPractice = {
                study = 0,
                hobbies = 0,
                communication = 0,
                emotional_intelligence = 0,
                charisma = 0,
            }
            registry:spawn({ switchRequest = { to = "week" } })
        end
    end
end

return PackOpeningSystem
