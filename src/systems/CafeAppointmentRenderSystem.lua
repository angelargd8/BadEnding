-- Draws Mizuki's Saturday dialogue and the five-card response hand.

local ImageManager = require("src.graphics.ImageManager")
local Screen = require("src.Screen")
local MIZUKI_LINES = require("src.data.mizuki_date")
local rules = require("src.data.cafe_appointment_rules")

local CafeAppointmentRenderSystem = { name = "cafeAppointmentRender" }

local titleFont, bodyFont, cardFont, hintFont
local mizukiImage

local CARD_W, CARD_H, CARD_GAP = 110, 82, 8
local CARD_ROW_W = rules.handSize * CARD_W + (rules.handSize - 1) * CARD_GAP
local CARD_X = math.floor((Screen.w - CARD_ROW_W) / 2)
local CARD_Y = 248

local TYPE_COLORS = {
    obsession = { 0.56, 0.39, 0.69 },
    hate = { 0.77, 0.31, 0.34 },
    friendship = { 0.23, 0.52, 0.37 },
}

local TYPE_LABELS = {
    obsession = "OBSESION",
    hate = "ODIO",
    friendship = "AMISTAD",
}

local OUTCOME_TEXT = {
    obsession = "La obsesion de Mizuki aumenta.",
    hate = "Sube el odio de Mizuki y baja su enamoramiento.",
    friendship = "Crece la posibilidad de una amistad honesta.",
}

function CafeAppointmentRenderSystem.setup(scene)
    titleFont = love.graphics.newFont(20)
    bodyFont = love.graphics.newFont(14)
    cardFont = love.graphics.newFont(10)
    hintFont = love.graphics.newFont(11)
    mizukiImage = ImageManager.load("assets/mizuki.png")
end

function CafeAppointmentRenderSystem.unload(scene)
    titleFont, bodyFont, cardFont, hintFont = nil, nil, nil, nil
    mizukiImage = nil
end

local function drawCard(card, index, used, selected)
    local x = CARD_X + (index - 1) * (CARD_W + CARD_GAP)
    local color = TYPE_COLORS[card.responseType] or { 0.30, 0.34, 0.40 }

    if used then
        color = { color[1] * 0.45, color[2] * 0.45, color[3] * 0.45 }
    end

    love.graphics.setColor(0.10, 0.09, 0.10, 1)
    love.graphics.rectangle("fill", x - 2, CARD_Y - 2,
        CARD_W + 4, CARD_H + 4, 5, 5)
    love.graphics.setColor(color[1], color[2], color[3], 1)
    love.graphics.rectangle("fill", x, CARD_Y, CARD_W, CARD_H, 4, 4)

    love.graphics.setColor(1, 1, 1, used and 0.55 or 0.92)
    love.graphics.setFont(cardFont)
    love.graphics.printf(("CARTA %d"):format(index), x + 4, CARD_Y + 12,
        CARD_W - 8, "center")
    love.graphics.printf(TYPE_LABELS[card.responseType] or "RESPUESTA",
        x + 4, CARD_Y + 34, CARD_W - 8, "center")
    if used then
        love.graphics.printf("USADA", x + 4, CARD_Y + 57,
            CARD_W - 8, "center")
    end

    if selected and not used then
        love.graphics.setColor(1, 0.88, 0.49, 1)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", x - 3, CARD_Y - 3,
            CARD_W + 6, CARD_H + 6, 5, 5)
        love.graphics.setLineWidth(1)
    end
end

function CafeAppointmentRenderSystem.draw(scene)
    local registry = scene.registry
    local battle = registry:resource("cafeAppointment")
    local runState = registry:resource("runState")

    love.graphics.clear(0.82, 0.62, 0.48, 1)
    love.graphics.setColor(0.24, 0.16, 0.14, 1)
    love.graphics.rectangle("fill", 0, 0, Screen.w, 38)
    love.graphics.setColor(0.96, 0.87, 0.73, 1)
    love.graphics.setFont(hintFont)
    love.graphics.print(("CAFETERIA  |  SABADO - 6 PM  |  INTERCAMBIO %d/%d")
        :format(math.min(battle.turn, rules.exchangeCount), rules.exchangeCount),
        18, 13)
    love.graphics.printf(("PROB. CITA %d%%"):format(battle.dateChance or 0),
        Screen.w - 150, 13, 136, "right")

    love.graphics.setColor(0.34, 0.23, 0.20, 1)
    love.graphics.rectangle("fill", 18, 52, 136, 132, 6, 6)
    love.graphics.setColor(1, 1, 1, 1)
    local avatarScale = math.min(128 / mizukiImage:getWidth(),
        128 / mizukiImage:getHeight())
    local avatarW = mizukiImage:getWidth() * avatarScale
    local avatarH = mizukiImage:getHeight() * avatarScale
    love.graphics.draw(mizukiImage,
        18 + (136 - avatarW) / 2, 52 + (132 - avatarH) / 2,
        0, avatarScale, avatarScale)

    love.graphics.setColor(0.96, 0.86, 0.72, 1)
    love.graphics.rectangle("fill", 164, 52, 450, 132, 6, 6)
    love.graphics.setColor(0.28, 0.19, 0.17, 1)
    love.graphics.setFont(cardFont)
    local speaker = battle.phase == "result" and "TU RESPUESTA" or "MIZUKI"
    love.graphics.print(speaker, 180, 65)
    love.graphics.setFont(bodyFont)

    local message
    if battle.phase == "result" then
        local response = battle.history[#battle.history]
        message = response and response.phrase or "..."
    elseif battle.phase == "complete" then
        message = battle.dateWon
            and "La cita tuvo un resultado positivo. Hay mas espacio para una amistad."
            or "La cita terminó con tensión. Sube el odio de Mizuki y baja su enamoramiento."
    else
        message = MIZUKI_LINES[battle.turn] or MIZUKI_LINES[#MIZUKI_LINES]
    end
    love.graphics.printf(message, 180, 89, 418, "left")

    love.graphics.setColor(0.24, 0.16, 0.14, 1)
    love.graphics.setFont(cardFont)
    local detail
    if battle.phase == "choose" then
        local card = battle.hand[battle.selected]
        detail = card and card.phrase or "No hay una carta seleccionada."
    elseif battle.phase == "result" then
        detail = OUTCOME_TEXT[battle.lastOutcome] or "La relacion cambia."
    elseif battle.phase == "complete" then
        local relation = runState.relationship
        detail = ("Probabilidad %d%%  |  %s  |  Obsesion %d   Odio %d   Amistad %d")
            :format(battle.dateChance or 0,
                battle.dateWon and "RESULTADO POSITIVO" or "RESULTADO NEGATIVO",
                relation.obsession or 0, relation.hate or 0,
                relation.friendshipness or 0)
    elseif battle.phase == "mizuki" then
        detail = "Ella empieza la conversacion. Presiona Enter para responder."
    else
        detail = "Selecciona una de tus cartas para responder."
    end
    love.graphics.setFont(hintFont)
    love.graphics.printf(detail, 32, 202, Screen.w - 64, "center")

    for index, card in ipairs(battle.hand) do
        drawCard(card, index, battle.used[index],
            battle.phase == "choose" and index == battle.selected)
    end

    love.graphics.setColor(0.27, 0.18, 0.16, 0.86)
    love.graphics.setFont(hintFont)
    local controls
    if battle.phase == "choose" then
        controls = "IZQ./DER. o A/D: ELEGIR  |  ENTER: RESPONDER"
    elseif battle.phase == "complete" then
        controls = "ENTER / ESPACIO / CLIC: VER RESUMEN DEL DOMINGO"
    elseif battle.phase == "result" then
        controls = "ENTER / ESPACIO / CLIC: SIGUIENTE INTERCAMBIO"
    else
        controls = "ENTER / ESPACIO / CLIC: ESCUCHAR Y RESPONDER"
    end
    love.graphics.printf(controls, 16, Screen.h - 24, Screen.w - 32, "center")

    love.graphics.setColor(1, 1, 1, 1)
end

return CafeAppointmentRenderSystem
