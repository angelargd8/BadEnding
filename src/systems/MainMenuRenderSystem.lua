local Screen = require("src.Screen")
local colors = require("src.data.menu_palette")

local MainMenuRenderSystem = { name = "mainMenuRender" }
local titleFont, buttonFont

local function drawFlower(x, y, radius)
    love.graphics.setColor(colors.rose)
    for petal = 0, 4 do
        local angle = petal * (2 * math.pi / 5)
        love.graphics.circle("fill",
            x + math.cos(angle) * radius * 1.25,
            y + math.sin(angle) * radius * 1.25,
            radius)
    end
    love.graphics.setColor(0.94, 0.74, 0.48, 1)
    love.graphics.circle("fill", x, y, radius * 0.65)
end

function MainMenuRenderSystem.setup(scene)
    titleFont = love.graphics.newFont(44)
    buttonFont = love.graphics.newFont(16)
end

function MainMenuRenderSystem.unload(scene)
    titleFont, buttonFont = nil, nil
end

function MainMenuRenderSystem.draw(scene)
    local menu = scene.registry:resource("mainMenu")

    love.graphics.clear(colors.beige)
    love.graphics.setColor(colors.red)
    love.graphics.rectangle("fill", Screen.w / 2 - 48, 64, 96, 4, 2, 2)

    love.graphics.setColor(colors.red)
    love.graphics.setFont(titleFont)
    love.graphics.printf("BAD ENDING", 24, 82, Screen.w - 48, "center")
    drawFlower(148, 108, 3.5)
    drawFlower(492, 108, 3.5)
    drawFlower(165, 130, 2.5)
    drawFlower(475, 130, 2.5)

    for i, option in ipairs(menu.options) do
        local enabled = option.action ~= "load" or menu.canLoad
        local selected = menu.selected == i
        local x, y, w, h = 196, option.y, 248, 34
        if selected then
            love.graphics.setColor(colors.rose)
            love.graphics.rectangle("fill", x - 2, y - 2, w + 4, h + 4, 7, 7)
        end
        love.graphics.setColor(colors.red)
        love.graphics.rectangle("fill", x, y, w, h, 5, 5)
        if selected then
            love.graphics.setColor(0.94, 0.74, 0.48, 1)
            love.graphics.rectangle("fill", x, y, 4, h, 2, 2)
        end
        love.graphics.setColor(1, 1, 1, enabled and 1 or 0.35)
        love.graphics.setFont(buttonFont)
        love.graphics.printf(option.label, x + 8, y + 7, w - 16, "center")
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return MainMenuRenderSystem
