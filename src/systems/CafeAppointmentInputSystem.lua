-- Runs four Saturday exchanges with Mizuki and a five-card response hand.

local CafeAppointmentInputSystem = { name = "cafeAppointmentInput" }
local MIZUKI_LINES = require("src.data.mizuki_date")
local rules = require("src.data.cafe_appointment_rules")
local Screen = require("src.Screen")
local Relationship = require("src.state.Relationship")
local WinChance = require("src.state.WinChance")

local FALLBACK_LINES = {
    "Prefiero conocerte como eres, no como te imagino.",
    "Me caes bien, pero quiero que hablemos con honestidad.",
    "No siempre se que decir, pero quiero intentarlo.",
    "Entiendo que esto sea importante para ti.",
    "No quiero fingir sentimientos que no tengo.",
}

local function sameCard(a, b)
    if a == b then return true end
    if a.collectionId ~= nil and b.collectionId ~= nil then
        return a.collectionId == b.collectionId
    end
    if a.phrase ~= b.phrase or a.responseType ~= b.responseType
            or a.primary ~= b.primary then
        return false
    end
    local aStats, bStats = a.stats or {}, b.stats or {}
    return aStats.int == bStats.int and aStats.charm == bStats.charm
        and aStats.sense == bStats.sense
end

local function consumePlayedCard(runState, card)
    local collection = runState.collection or {}
    for index = #collection, 1, -1 do
        if sameCard(collection[index], card) then
            table.remove(collection, index)
            return
        end
    end
end

local function makeBattle(runState)
    local collection = runState.collection or {}
    local hand = runState.nextDateDeck or {}
    if #hand == 0 then
        local first = math.max(1, #collection - rules.handSize + 1)
        for i = first, #collection do
            hand[#hand + 1] = collection[i]
        end
    end
    runState.nextDateDeck = nil

    -- The normal Saturday flow has a full pack. Fill any missing slots so
    -- the date remains playable when launched directly from the debug UI.
    while #hand < rules.handSize do
        local index = #hand + 1
        hand[index] = {
            phrase = FALLBACK_LINES[index],
            responseType = "friendship",
            primary = "sense",
            stats = { int = 0, charm = 0, sense = 1 },
        }
    end

    return {
        turn = 1,
        phase = "mizuki",
        selected = 1,
        hand = hand,
        used = {},
        history = {},
        lastOutcome = nil,
    }
end

local function firstAvailable(battle, start, direction)
    local count = #battle.hand
    for offset = 0, count - 1 do
        local index = ((start - 1 + direction * offset) % count) + 1
        if not battle.used[index] then return index end
    end
    return battle.selected
end

local function selectCard(battle, direction)
    if #battle.hand == 0 then return end
    local start = battle.selected + direction
    battle.selected = firstAvailable(battle, start, direction)
end

local function playSelectedCard(battle, runState)
    local card = battle.hand[battle.selected]
    if not card or battle.used[battle.selected] then return end

    local responseType = Relationship.applyCard(runState, card.responseType)
    consumePlayedCard(runState, card)
    battle.used[battle.selected] = true
    battle.history[#battle.history + 1] = {
        responseType = responseType,
        phrase = card.phrase,
    }
    battle.dateChance = WinChance.date(runState, battle)
    battle.lastOutcome = responseType
    battle.phase = "result"
end

local function resolveDate(battle, runState)
    if battle.dateResolved then return end

    battle.dateChance = battle.dateChance or WinChance.date(runState, battle)
    battle.dateWon = WinChance.roll(battle.dateChance)
    battle.dateResolved = true

    local resultKey = battle.dateWon and "friendshipness" or "hate"
    Relationship.addPoint(runState, resultKey)
end

local function advance(battle, runState, registry)
    if battle.phase == "mizuki" then
        battle.phase = "choose"
    elseif battle.phase == "choose" then
        playSelectedCard(battle, runState)
    elseif battle.phase == "result" then
        if battle.turn >= rules.exchangeCount
                or battle.turn >= #battle.hand then
            battle.phase = "complete"
            resolveDate(battle, runState)
        else
            battle.turn = battle.turn + 1
            battle.selected = firstAvailable(battle, battle.selected + 1, 1)
            battle.phase = "mizuki"
        end
    elseif battle.phase == "complete" then
        resolveDate(battle, runState)
        runState.day = 7
        runState.timeOfDay = "AM"
        registry:spawn({ switchRequest = { to = "sundaySummary" } })
    end
end

function CafeAppointmentInputSystem.setup(scene)
    local registry = scene.registry
    local runState = registry:resource("runState")
    if runState then
        runState.day = 6
        runState.timeOfDay = "6 PM"
    end
    local battle = registry:resource("cafeAppointment")
    if not battle or type(battle.hand) ~= "table"
            or #battle.hand ~= rules.handSize then
        battle = makeBattle(runState or {})
        battle.dateChance = WinChance.date(runState, battle)
        registry:setResource("cafeAppointment", battle)
    elseif not battle.dateChance then
        battle.dateChance = WinChance.date(runState, battle)
    end
end

function CafeAppointmentInputSystem.update(scene)
    local registry = scene.registry
    if registry:first("switchRequest") then return end
    local runState = registry:resource("runState")
    local battle = registry:resource("cafeAppointment")

    for _, key in registry:each("keyPressed") do
        if battle.phase == "choose"
                and (key.key == "left" or key.key == "a") then
            selectCard(battle, -1)
        elseif battle.phase == "choose"
                and (key.key == "right" or key.key == "d") then
            selectCard(battle, 1)
        elseif key.key == "space" or key.key == "return" then
            advance(battle, runState, registry)
        end
    end

    if battle.phase == "choose" then
        for _, mouse in registry:each("mousePressed") do
            if mouse.button == 1 and mouse.y >= 254 and mouse.y <= 338 then
                local cardWidth, gap = 110, 8
                local rowWidth = rules.handSize * cardWidth
                    + (rules.handSize - 1) * gap
                local startX = math.floor((Screen.w - rowWidth) / 2)
                local index = math.floor((mouse.x - startX) / (cardWidth + gap)) + 1
                local cardLeft = startX + (index - 1) * (cardWidth + gap)
                if index >= 1 and index <= #battle.hand
                        and mouse.x >= cardLeft
                        and mouse.x <= cardLeft + cardWidth then
                    battle.selected = index
                    advance(battle, runState, registry)
                end
            end
        end
    elseif battle.phase ~= "choose" then
        for _, mouse in registry:each("mousePressed") do
            if mouse.button == 1 then
                advance(battle, runState, registry)
                break
            end
        end
    end
end

return CafeAppointmentInputSystem
