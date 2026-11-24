-- Shows the friendship victory and any relationship or activity setbacks.

local Screen = require("src.Screen")
local colors = require("src.data.menu_palette")

local EndingRenderSystem = { name = "endingRender" }
local titleFont, messageFont, hintFont

local function defeatMessage(result)
    local failedStudy = not result.studyMet
    local failedHappiness = not result.happinessMet
    local relationshipMessage = result.relationship == "hate"
        and "Mizuki terminó odiándote."
        or result.relationship == "obsession"
            and "Mizuki quedó obsesionada contigo."
            or nil
    local activityMessage

    if failedStudy and failedHappiness then
        activityMessage = "Descuidaste tus estudios y tus pasatiempos. No te graduarás y también perdiste tiempo con tus amigos."
    elseif failedStudy then
        activityMessage = "Pasaste mucho tiempo con tus amigos y en tus pasatiempos, pero descuidaste los estudios y no te graduarás."
    elseif failedHappiness then
        activityMessage = "Pasaste mucho tiempo estudiando y aprendiendo inteligencia emocional, pero descuidaste a tus amigos y tus pasatiempos. No eres feliz."
    end

    if activityMessage and relationshipMessage then
        return activityMessage .. " " .. relationshipMessage
    end
    return activityMessage or relationshipMessage
end

function EndingRenderSystem.setup(scene)
    titleFont = love.graphics.newFont(34)
    messageFont = love.graphics.newFont(19)
    hintFont = love.graphics.newFont(12)
end

function EndingRenderSystem.unload(scene)
    titleFont, messageFont, hintFont = nil, nil, nil
end

function EndingRenderSystem.draw(scene)
    local ending = scene.registry:resource("ending")
    local result = ending.result
    local won = type(result) == "table" and result.won == true
        or result == "friends"
    local messages = {}

    if won then
        messages[1] = "Ahora Mizuki y tú son amigos."
    elseif type(result) == "table" then
        messages[1] = defeatMessage(result)
    elseif result == "hate" then
        messages[1] = "Mizuki terminó odiándote."
    else
        messages[1] = "Mizuki quedó obsesionada contigo."
    end

    love.graphics.clear(won and colors.beige or colors.red)
    if won then
        love.graphics.setColor(colors.red)
        love.graphics.rectangle("fill", 225, 82, 190, 4, 2, 2)
    end

    love.graphics.setColor(won and colors.black or colors.beige)
    love.graphics.setFont(titleFont)
    love.graphics.printf(won and "GANASTE" or "PERDISTE",
        30, 122, Screen.w - 60, "center")

    love.graphics.setFont(messageFont)
    for index, message in ipairs(messages) do
        love.graphics.printf(message, 48, 176 + (index - 1) * 48,
            Screen.w - 96, "center")
    end

    local hint = "ENTER / ESPACIO / CLIC: VOLVER AL MENU"
    local hintY = Screen.h - 46
    if won then
        local width = math.max(248, hintFont:getWidth(hint) + 32)
        love.graphics.setColor(colors.red)
        love.graphics.rectangle("fill", (Screen.w - width) / 2, hintY - 8,
            width, hintFont:getHeight() + 16, 5, 5)
        love.graphics.setColor(1, 1, 1, 1)
    end
    love.graphics.setFont(hintFont)
    love.graphics.printf(hint, 24, hintY, Screen.w - 48, "center")
    love.graphics.setColor(1, 1, 1, 1)
end

return EndingRenderSystem
