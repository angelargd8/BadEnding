-- Generates and stores one five-card pack for each completed week.

local CardGenerator = require("src.generation.CardGenerator")
local rules = require("src.data.card_rules")
local SaveFile = require("src.state.SaveFile")
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
            runState.practice or runState.weekPractice,
            runState.week,
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
        if (opening.ready or opening.finished) and runState.day == 6 then
            runState.timeOfDay = "AM"
            SaveFile.save({
                runState = runState,
                scene = "homeInterior",
                payload = { x = 288, y = 288 },
            })
            registry:spawn({
                switchRequest = {
                    to = "homeInterior",
                    payload = { x = 288, y = 288 },
                },
            })
        end
    end
end

return PackOpeningSystem
