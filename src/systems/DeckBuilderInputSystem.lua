-- Handles card selection and starting the next date.

local rules = require("src.data.deck_builder_rules")

local DeckBuilderInputSystem = { name = "deckBuilderInput" }

local function ensureCollectionIds(runState)
    local collection = runState.collection or {}
    local nextId = tonumber(runState.nextCollectionCardId) or 1

    for _, card in ipairs(collection) do
        local id = tonumber(card.collectionId)
        if id and id >= nextId then nextId = id + 1 end
    end
    for _, card in ipairs(collection) do
        if card.collectionId == nil then
            card.collectionId = nextId
            nextId = nextId + 1
        end
    end

    runState.nextCollectionCardId = nextId
end

local function selectedPosition(state, cardIndex)
    for i, index in ipairs(state.selected) do
        if index == cardIndex then return i end
    end
end

local function pageStart(state)
    return math.floor((state.cursor - 1) / rules.visibleCards)
        * rules.visibleCards + 1
end

local function toggleCard(state, cardIndex, collectionSize)
    if cardIndex < 1 or cardIndex > collectionSize then return end
    local selected = selectedPosition(state, cardIndex)
    if selected then
        table.remove(state.selected, selected)
        state.message = "Carta retirada del mazo."
    elseif #state.selected < rules.handSize then
        state.selected[#state.selected + 1] = cardIndex
        state.message = #state.selected == rules.handSize
            and "Mazo completo. Ya puedes iniciar la cita."
            or "Carta agregada al mazo."
    else
        state.message = "El mazo admite cinco cartas."
    end
end

local function startDate(state, runState, registry)
    if #state.selected ~= rules.handSize then
        state.message = "Selecciona cinco cartas para continuar."
        return
    end

    local deck = {}
    for _, index in ipairs(state.selected) do
        deck[#deck + 1] = runState.collection[index]
    end
    runState.nextDateDeck = deck
    runState.day = 6
    runState.timeOfDay = "6 PM"
    registry:spawn({ switchRequest = { to = "cafeAppointment" } })
end

local function moveCursor(state, delta, collectionSize)
    state.cursor = math.max(1, math.min(collectionSize, state.cursor + delta))
end

local function clickedCard(state, mouse, collectionSize)
    local rowH = rules.cardH + rules.gapY
    local localY = mouse.y - rules.cardY
    local row = math.floor(localY / rowH)
    if row < 0 or row >= 2 then return end
    local rowY = rules.cardY + row * rowH
    if mouse.y < rowY or mouse.y > rowY + rules.cardH then return end

    local localX = mouse.x - rules.cardX
    local colW = rules.cardW + rules.gapX
    local col = math.floor(localX / colW)
    if col < 0 or col >= rules.columns then return end
    local cardX = rules.cardX + col * colW
    if mouse.x < cardX or mouse.x > cardX + rules.cardW then return end

    local cardIndex = pageStart(state) + row * rules.columns + col
    if cardIndex <= collectionSize then
        state.cursor = cardIndex
        toggleCard(state, cardIndex, collectionSize)
    end
end

function DeckBuilderInputSystem.setup(scene)
    local registry = scene.registry
    ensureCollectionIds(registry:resource("runState"))
    if not registry:resource("deckBuilder") then
        registry:setResource("deckBuilder", {
            cursor = 1,
            selected = {},
            message = "Selecciona cinco cartas de tu coleccion.",
        })
    end
end

function DeckBuilderInputSystem.update(scene)
    local registry = scene.registry
    if registry:first("switchRequest") then return end
    local runState = registry:resource("runState")
    local state = registry:resource("deckBuilder")
    local collectionSize = #runState.collection

    for _, key in registry:each("keyPressed") do
        if key.key == "left" then
            moveCursor(state, -1, collectionSize)
        elseif key.key == "right" then
            moveCursor(state, 1, collectionSize)
        elseif key.key == "up" then
            moveCursor(state, -rules.columns, collectionSize)
        elseif key.key == "down" then
            moveCursor(state, rules.columns, collectionSize)
        elseif key.key == "pageup" then
            moveCursor(state, -rules.visibleCards, collectionSize)
        elseif key.key == "pagedown" then
            moveCursor(state, rules.visibleCards, collectionSize)
        elseif key.key == "space" then
            toggleCard(state, state.cursor, collectionSize)
        elseif key.key == "return" then
            startDate(state, runState, registry)
        end
    end

    for _, mouse in registry:each("mousePressed") do
        if mouse.button == 1 then
            local startButton = rules.startButton
            if mouse.x >= startButton.x
                    and mouse.x <= startButton.x + startButton.w
                    and mouse.y >= startButton.y
                    and mouse.y <= startButton.y + startButton.h then
                startDate(state, runState, registry)
            else
                clickedCard(state, mouse, collectionSize)
            end
        end
    end
end

return DeckBuilderInputSystem
