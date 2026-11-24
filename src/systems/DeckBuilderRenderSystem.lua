-- Draws the collection grid, selected deck, and start button.

local Screen = require("src.Screen")
local rules = require("src.data.deck_builder_rules")
local palette = require("src.data.menu_palette")

local DeckBuilderRenderSystem = { name = "deckBuilderRender" }
local titleFont, cardFont, detailFont, hintFont

local TYPE_COLORS = {
    obsession = palette.rose,
    hate = palette.red,
    friendship = palette.beige,
}

local TYPE_LABELS = {
    obsession = "OBSESION",
    hate = "ODIO",
    friendship = "AMISTAD",
}

local STAT_LABELS = { int = "ESTUDIO", charm = "CARISMA", sense = "IE" }

function DeckBuilderRenderSystem.setup(scene)
    titleFont = love.graphics.newFont(18)
    cardFont = love.graphics.newFont(10)
    detailFont = love.graphics.newFont(11)
    hintFont = love.graphics.newFont(10)
end

function DeckBuilderRenderSystem.unload(scene)
    titleFont, cardFont, detailFont, hintFont = nil, nil, nil, nil
end

local function selectedPositions(state)
    local positions = {}
    for order, index in ipairs(state.selected) do
        positions[index] = order
    end
    return positions
end

local function drawCard(card, index, x, y, state, selectedOrder)
    local color = TYPE_COLORS[card.responseType] or { 0.30, 0.34, 0.40 }
    love.graphics.setColor(palette.black)
    love.graphics.rectangle("fill", x - 2, y - 2,
        rules.cardW + 4, rules.cardH + 4, 5, 5)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, rules.cardW, rules.cardH, 4, 4)

    love.graphics.setColor(card.responseType == "friendship"
        and palette.black or palette.beige)
    love.graphics.setFont(cardFont)
    love.graphics.printf(("CARTA %d"):format(index), x + 4, y + 9,
        rules.cardW - 8, "center")
    love.graphics.printf(TYPE_LABELS[card.responseType] or "RESPUESTA",
        x + 4, y + 29, rules.cardW - 8, "center")
    love.graphics.printf(STAT_LABELS[card.primary] or "", x + 4, y + 49,
        rules.cardW - 8, "center")

    local selected = selectedOrder ~= nil
    if selected then
        love.graphics.setColor(palette.beige)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x - 3, y - 3,
            rules.cardW + 6, rules.cardH + 6, 5, 5)
        love.graphics.setLineWidth(1)
        love.graphics.setFont(cardFont)
        love.graphics.printf(("MAZO %d"):format(selectedOrder), x + 4, y + 64,
            rules.cardW - 8, "center")
    elseif index == state.cursor then
        love.graphics.setColor(palette.beige)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", x - 3, y - 3,
            rules.cardW + 6, rules.cardH + 6, 5, 5)
        love.graphics.setLineWidth(1)
    end
end

local function drawButton(button, label, enabled)
    love.graphics.setColor(enabled and palette.red or palette.peach)
    love.graphics.rectangle("fill", button.x, button.y,
        button.w, button.h, 5, 5)
    love.graphics.setColor(enabled and palette.beige or palette.black)
    love.graphics.setFont(detailFont)
    love.graphics.printf(label, button.x + 6, button.y + 11,
        button.w - 12, "center")
end

function DeckBuilderRenderSystem.draw(scene)
    local registry = scene.registry
    local runState = registry:resource("runState")
    local state = registry:resource("deckBuilder")
    local collection = runState.collection
    local positions = selectedPositions(state)
    local pageStart = math.floor((state.cursor - 1) / rules.visibleCards)
        * rules.visibleCards + 1

    love.graphics.clear(palette.black)
    love.graphics.setColor(palette.red)
    love.graphics.rectangle("fill", 0, 0, Screen.w, 38)
    love.graphics.setColor(palette.beige)
    love.graphics.setFont(titleFont)
    love.graphics.print("MAZO PARA LA CITA", 18, 10)
    love.graphics.setFont(detailFont)
    love.graphics.printf(("CARTAS %d/5"):format(#state.selected),
        420, 13, 202, "right")

    for slot = 0, rules.visibleCards - 1 do
        local index = pageStart + slot
        local card = collection[index]
        if card then
            local row = math.floor(slot / rules.columns)
            local col = slot % rules.columns
            local x = rules.cardX + col * (rules.cardW + rules.gapX)
            local y = rules.cardY + row * (rules.cardH + rules.gapY)
            drawCard(card, index, x, y, state, positions[index])
        end
    end

    local card = collection[state.cursor]
    love.graphics.setColor(palette.beige)
    love.graphics.setFont(hintFont)
    love.graphics.printf(state.message or "", 20, 240,
        Screen.w - 40, "center")
    love.graphics.setColor(palette.beige)
    love.graphics.setFont(detailFont)
    love.graphics.printf(card and card.phrase or "No hay una carta seleccionada.",
        24, 258, Screen.w - 48, "center")

    local enoughCards = #state.selected == rules.handSize
    drawButton(rules.startButton, "EMPEZAR CITA", enoughCards)

    love.graphics.setColor(palette.rose)
    love.graphics.setFont(hintFont)
    local page = math.floor((pageStart - 1) / rules.visibleCards) + 1
    local pageCount = math.max(1,
        math.ceil(#collection / rules.visibleCards))
    love.graphics.printf(("FLECHAS: MOVER  |  ESPACIO: ELEGIR  |  ENTER: EMPEZAR  |  PAGINA %d/%d")
        :format(page, pageCount), 16, 354, Screen.w - 32, "center")
    love.graphics.setColor(palette.beige)
end

return DeckBuilderRenderSystem
