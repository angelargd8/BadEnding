-- Presents the week's stats, activity counts, and Mizuki's relationship level.

local Screen = require("src.Screen")
local RunState = require("src.state.RunState")
local Relationship = require("src.state.Relationship")
local EndingRules = require("src.state.EndingRules")
local palette = require("src.data.menu_palette")

local SundaySummaryRenderSystem = { name = "sundaySummaryRender" }
local titleFont, valueFont, labelFont, hintFont

function SundaySummaryRenderSystem.setup(scene)
    titleFont = love.graphics.newFont(26)
    valueFont = love.graphics.newFont(26)
    labelFont = love.graphics.newFont(12)
    hintFont = love.graphics.newFont(11)
end

function SundaySummaryRenderSystem.unload(scene)
    titleFont, valueFont, labelFont, hintFont = nil, nil, nil, nil
end

local function percent(value)
    return math.floor(value + 0.5)
end

local function drawProgressBar(x, y, width, height, value, color, threshold)
    local shown = math.max(0, math.min(100, value))
    love.graphics.setColor(palette.black)
    love.graphics.rectangle("fill", x, y, width, height, 4, 4)
    if shown > 0 then
        love.graphics.setColor(color[1], color[2], color[3], 1)
        love.graphics.rectangle("fill", x, y,
            width * shown / 100, height, 4, 4)
    end
    if threshold then
        local markerX = x + width * threshold / 100
        love.graphics.setColor(palette.rose)
        love.graphics.setLineWidth(2)
        love.graphics.line(markerX, y - 2, markerX, y + height + 2)
        love.graphics.setLineWidth(1)
    end
end

function SundaySummaryRenderSystem.draw(scene)
    local runState = scene.registry:resource("runState")
    local stats = runState.stats
    local practiced = runState.weekPractice or {}
    local relationship = Relationship.rates(runState)
    local activity = EndingRules.activityRates(runState)

    love.graphics.clear(palette.black)
    love.graphics.setColor(palette.beige)
    love.graphics.rectangle("fill", 246, 13, 148, 3, 2, 2)
    love.graphics.setColor(palette.beige)
    love.graphics.setFont(titleFont)
    love.graphics.printf("DOMINGO · RESUMEN", 24, 22,
        Screen.w - 48, "center")

    love.graphics.setColor(palette.beige)
    love.graphics.setFont(labelFont)
    love.graphics.printf(("SEMANA %d COMPLETADA"):format(runState.week),
        24, 55, Screen.w - 48, "center")

    local values = {
        { label = "ESTUDIO", value = stats.int },
        { label = "FELICIDAD", value = runState.practice.hobbies or 0 },
        { label = "INTELIGENCIA\nEMOCIONAL", value = stats.sense },
    }
    local cardW, cardY, cardH, gap = 176, 82, 76, 16
    local total = cardW * 3 + gap * 2
    local startX = (Screen.w - total) / 2
    for i, item in ipairs(values) do
        local x = startX + (i - 1) * (cardW + gap)
        love.graphics.setColor(palette.beige)
        love.graphics.rectangle("fill", x, cardY, cardW, cardH, 8, 8)
        local accents = {
            palette.black,
            palette.rose,
            palette.red,
        }
        love.graphics.setColor(accents[i])
        love.graphics.rectangle("fill", x + 12, cardY + 8, 3, cardH - 16, 2, 2)
        love.graphics.setColor(palette.black)
        love.graphics.setFont(labelFont)
        love.graphics.printf(item.label, x + 20, cardY + 9,
            cardW - 28, "center")
        love.graphics.setFont(valueFont)
        local valueY = cardY + (i == 3 and 41 or 34)
        love.graphics.printf(tostring(item.value or 0), x + 20,
            valueY, cardW - 24, "center")
    end

    love.graphics.setColor(palette.beige)
    love.graphics.setFont(labelFont)
    love.graphics.printf("RELACIÓN CON MIZUKI", 24, 162,
        Screen.w - 48, "center")

    local barX, barY, barW, barH = 70, 183, 500, 14
    love.graphics.setColor(palette.peach)
    love.graphics.rectangle("fill", barX, barY, barW, barH, 5, 5)
    local sections = {
        { value = relationship.obsession, color = palette.red },
        { value = relationship.hate, color = palette.black },
        { value = relationship.friendship, color = palette.rose },
    }
    local offset = 0
    for _, section in ipairs(sections) do
        local width = barW * section.value / 100
        if width > 0 then
            love.graphics.setColor(section.color)
            love.graphics.rectangle("fill", barX + offset, barY,
                width, barH)
            offset = offset + width
        end
    end
    love.graphics.setColor(palette.black)
    love.graphics.setLineWidth(2)
    love.graphics.line(barX + barW * 0.15, barY - 3,
        barX + barW * 0.15, barY + barH + 3)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(palette.beige)
    love.graphics.setFont(hintFont)
    local relationshipText = ("ENAMORAMIENTO %d%%   ODIO %d%%   AMISTAD %d%%")
        :format(percent(relationship.obsession), percent(relationship.hate),
            percent(relationship.friendship))
    love.graphics.printf(relationshipText, 24, 202,
        Screen.w - 48, "center")
    love.graphics.setColor(palette.beige)
    love.graphics.printf("META: ENAMORAMIENTO MENOR A 15%", 24, 220,
        Screen.w - 48, "center")

    love.graphics.setColor(palette.beige)
    love.graphics.setFont(labelFont)
    love.graphics.printf("ACTIVIDADES DE LA SEMANA", 24, 248,
        Screen.w - 48, "center")
    local practiceText = ("Estudio %d   Pasatiempos %d   Comunicacion %d   IE %d   Carisma %d")
        :format(practiced.study or 0, practiced.hobbies or 0,
            practiced.communication or 0,
            practiced.emotional_intelligence or 0,
            practiced.charisma or 0)
    love.graphics.setColor(palette.beige)
    love.graphics.printf(practiceText, 20, 270, Screen.w - 40, "center")

    love.graphics.setFont(hintFont)
    love.graphics.setColor(palette.beige)
    love.graphics.printf(("NIVEL DE ESTUDIO %d%%")
        :format(percent(activity.study)), 48, 296, 244, "center")
    love.graphics.printf(("NIVEL DE FELICIDAD %d%%")
        :format(percent(activity.happiness)), 348, 296, 244, "center")
    drawProgressBar(60, 315, 220, 10, activity.study,
        palette.red, EndingRules.MIN_STUDY_PERCENT)
    drawProgressBar(360, 315, 220, 10, activity.happiness,
        palette.rose, EndingRules.MIN_HAPPINESS_PERCENT)

    love.graphics.setColor(palette.beige)
    love.graphics.printf("META: ESTUDIO >30% Y FELICIDAD >30%",
        16, 335, Screen.w - 32, "center")

    love.graphics.setColor(palette.beige)
    love.graphics.setFont(hintFont)
    local hint = runState.week >= RunState.MAX_WEEKS
        and "Haz clic o presiona ESPACIO para ver el final"
        or "Haz clic o presiona ESPACIO para comenzar la siguiente semana"
    love.graphics.printf(hint, 20, Screen.h - 25,
        Screen.w - 40, "center")
    love.graphics.setColor(palette.beige)
end

return SundaySummaryRenderSystem
