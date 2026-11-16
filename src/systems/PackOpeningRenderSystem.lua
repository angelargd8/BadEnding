-- Renders Saturday's five square cards and the meaning icon beneath each.

local ImageManager = require("src.graphics.ImageManager")
local Screen = require("src.Screen")

local PackOpeningRenderSystem = { name = "packOpeningRender" }

local CARD_SIZE = 66
local CARD_GAP = 28
local ICON_SIZE = 30

local CARD_COLORS = {
    obsession = { 0.56, 0.39, 0.69 },
    hate = { 0.77, 0.31, 0.34 },
    friendship = { 0.23, 0.52, 0.37 },
}

local TYPE_LABELS = {
    obsession = "OBSESIÓN",
    hate = "ODIO",
    friendship = "AMISTAD",
}

local STAT_ICONS = {
    int = "assets/estudiar.png",
    charm = "assets/comunicacion.png",
    sense = "assets/inteligenciaEmocional.png",
}

local STAT_LABELS = {
    int = "ESTUDIO",
    charm = "COMUNICACIÓN",
    sense = "INT. EMOCIONAL",
}

local titleFont, cardFont, detailFont, smallFont
local icons

function PackOpeningRenderSystem.setup(scene)
    titleFont = love.graphics.newFont(22)
    cardFont = love.graphics.newFont(10)
    detailFont = love.graphics.newFont(15)
    smallFont = love.graphics.newFont(11)

    icons = {}
    for stat, path in pairs(STAT_ICONS) do
        icons[stat] = ImageManager.load(path)
        icons[stat]:setFilter("linear", "linear")
    end
end

function PackOpeningRenderSystem.unload(scene)
    titleFont, cardFont, detailFont, smallFont = nil, nil, nil, nil
    icons = nil
end

local function drawCard(card, index, x, y, selected)
    local color = CARD_COLORS[card.responseType] or { 0.38, 0.40, 0.48 }
    love.graphics.setColor(0.06, 0.07, 0.11)
    love.graphics.rectangle("fill", x - 2, y - 2, CARD_SIZE + 4,
        CARD_SIZE + 4, 5, 5)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x, y, CARD_SIZE, CARD_SIZE, 4, 4)

    love.graphics.setColor(1, 1, 1, 0.78)
    love.graphics.setFont(cardFont)
    love.graphics.printf(("CARTA %d"):format(index), x + 3, y + 8,
        CARD_SIZE - 6, "center")
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(cardFont)
    love.graphics.printf(TYPE_LABELS[card.responseType] or "RESPUESTA",
        x + 3, y + 30, CARD_SIZE - 6, "center")

    if selected then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", x - 3, y - 3, CARD_SIZE + 6,
            CARD_SIZE + 6, 5, 5)
        love.graphics.setLineWidth(1)
    end

    love.graphics.setColor(0.94, 0.89, 0.76)
    love.graphics.rectangle("fill", x + (CARD_SIZE - ICON_SIZE - 8) / 2,
        y + CARD_SIZE + 6, ICON_SIZE + 8, ICON_SIZE + 8, 4, 4)

    local image = icons[card.primary]
    if image then
        local scale = math.min(ICON_SIZE / image:getWidth(),
            ICON_SIZE / image:getHeight())
        local width, height = image:getWidth() * scale,
            image:getHeight() * scale
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(image,
            x + (CARD_SIZE - width) / 2,
            y + CARD_SIZE + 10 + (ICON_SIZE - height) / 2,
            0, scale, scale)
    end

    love.graphics.setColor(1, 1, 1, 0.78)
    love.graphics.setFont(cardFont)
    love.graphics.printf(STAT_LABELS[card.primary] or "HABILIDAD",
        x - 12, y + CARD_SIZE + ICON_SIZE + 13, CARD_SIZE + 24, "center")
end

function PackOpeningRenderSystem.draw(scene)
    local registry = scene.registry
    local runState = registry:resource("runState")
    local opening = registry:resource("packOpening")
    local cards = opening.cards
    local totalWidth = #cards * CARD_SIZE
        + math.max(0, #cards - 1) * CARD_GAP
    local startX = (Screen.w - totalWidth) / 2
    local cardY = 104

    love.graphics.clear(0.055, 0.065, 0.105, 1)
    love.graphics.setColor(0.94, 0.89, 0.76)
    love.graphics.setFont(titleFont)
    love.graphics.printf("SÁBADO · APERTURA DE SOBRE", 20, 22,
        Screen.w - 40, "center")

    love.graphics.setFont(smallFont)
    love.graphics.setColor(1, 1, 1, 0.68)
    local subtitle = ("Semana %d · 5 cartas nuevas · %d en el mazo"):format(
        runState.week, #runState.collection)
    love.graphics.printf(subtitle, 20, 55, Screen.w - 40, "center")

    for index, card in ipairs(cards) do
        local x = startX + (index - 1) * (CARD_SIZE + CARD_GAP)
        drawCard(card, index, x, cardY, index == opening.selected)
    end

    local selectedCard = cards[opening.selected]
    love.graphics.setColor(0.12, 0.14, 0.21, 1)
    love.graphics.rectangle("fill", 24, 278, Screen.w - 48, 82, 5, 5)
    if selectedCard then
        love.graphics.setColor(0.94, 0.89, 0.76)
        love.graphics.setFont(detailFont)
        love.graphics.printf(selectedCard.phrase, 38, 288,
            Screen.w - 76, "center")
        love.graphics.setFont(smallFont)
        love.graphics.setColor(1, 1, 1, 0.72)
        love.graphics.printf(("EST %d   COM %d   IE %d"):format(
            selectedCard.stats.int,
            selectedCard.stats.charm,
            selectedCard.stats.sense), 38, 333, Screen.w - 76, "center")
    else
        love.graphics.setColor(0.94, 0.89, 0.76)
        love.graphics.setFont(detailFont)
        love.graphics.printf("El sobre estará disponible al terminar la semana.",
            38, 305, Screen.w - 76, "center")
    end

    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.setFont(smallFont)
    local instruction, instructionY
    if opening.finished then
        instruction = "FIN DE LAS SEIS SEMANAS · C: ABRIR COLECCIÓN"
        instructionY = 374
    elseif opening.ready then
        instruction = "IZQ./DER. o A/D: elegir carta · C: abrir colección\nEnter/Espacio: comenzar la próxima semana"
        instructionY = 361
    else
        instruction = "C: abrir colección · las cartas se conservan hasta usarlas"
        instructionY = 374
    end
    love.graphics.printf(instruction, 12, instructionY, Screen.w - 24, "center")
    love.graphics.setColor(1, 1, 1)
end

return PackOpeningRenderSystem
