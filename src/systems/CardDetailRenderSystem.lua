-- Exact values live here, not in the procedural picture. The collection grid
-- should communicate a card's shape at a glance; this panel answers precisely.

local CardDetailRenderSystem = { name = "cardDetailRender" }
local palette = require("src.data.menu_palette")

local COLORS = {
    cream = palette.beige,
    ink = palette.black,
    int = palette.beige,
    charm = palette.rose,
    sense = palette.red,
    obsession = palette.rose,
    hate = palette.red,
    friendship = palette.beige,
}

local LABELS = { int = "EST", charm = "COM", sense = "IE" }
local RESPONSE_LABELS = {
    obsession = "REFUERZA LA IDEALIZACIÓN",
    hate = "SUBE EL ODIO · BAJA EL ENAMORAMIENTO",
    friendship = "FAVORECE LA AMISTAD",
}
local titleFont, bodyFont, numberFont, smallFont

function CardDetailRenderSystem.setup(scene)
    titleFont = love.graphics.newFont(11)
    bodyFont = love.graphics.newFont(14)
    numberFont = love.graphics.newFont(20)
    smallFont = love.graphics.newFont(9)
end

function CardDetailRenderSystem.unload(scene)
    titleFont, bodyFont, numberFont, smallFont = nil, nil, nil, nil
end

function CardDetailRenderSystem.draw(scene)
    local registry = scene.registry
    local collection = registry:resource("runState").collection
    local view = registry:resource("collectionView")
    local card = collection[view.selected]

    if not card then
        love.graphics.setColor(COLORS.cream[1], COLORS.cream[2], COLORS.cream[3], 0.45)
        love.graphics.setFont(bodyFont)
        love.graphics.printf("Aún no hay respuestas.", 24, 170, 182, "center")
        return
    end

    love.graphics.setColor(COLORS[card.primary])
    love.graphics.setFont(titleFont)
    love.graphics.print(LABELS[card.primary] .. " · PRINCIPAL", 16, 69)

    love.graphics.setColor(COLORS[card.responseType] or COLORS.cream)
    love.graphics.setFont(smallFont)
    love.graphics.print(RESPONSE_LABELS[card.responseType] or "RESPUESTA", 16, 83)

    love.graphics.setColor(COLORS.cream)
    love.graphics.setFont(bodyFont)
    love.graphics.printf(card.phrase, 16, 99, 198, "left")

    love.graphics.setFont(smallFont)
    love.graphics.setColor(COLORS.cream[1], COLORS.cream[2], COLORS.cream[3], 0.42)
    love.graphics.print("HABILIDADES DE ESTA CARTA", 16, 187)

    local stats = { "int", "charm", "sense" }
    for i, name in ipairs(stats) do
        local x = 16 + (i - 1) * 67
        love.graphics.setColor(COLORS[name])
        love.graphics.setFont(numberFont)
        love.graphics.print(('%02d'):format(card.stats[name]), x, 210)
        love.graphics.setFont(smallFont)
        love.graphics.print(LABELS[name], x + 1, 235)
    end

    love.graphics.setColor(COLORS.cream[1], COLORS.cream[2], COLORS.cream[3], 0.18)
    love.graphics.line(16, 262, 214, 262)
    love.graphics.setColor(COLORS.cream[1], COLORS.cream[2], COLORS.cream[3], 0.50)
    love.graphics.setFont(smallFont)
    love.graphics.printf(
        "La imagen muestra la combinación.\nLos números muestran sus valores.",
        16, 278, 198, "left")
    love.graphics.setColor(1, 1, 1)
end

return CardDetailRenderSystem
