-- Draws every menu: a horizontal row of icons, a cursor on the active
-- one, the selected option's name underneath. Pure presentation — the
-- cursor only MOVES in MenuInputSystem; this system just looks at the
-- component and paints what it sees.
--
-- Icons are colored squares with a letter until the sprite lesson,
-- the same placeholder move as pong's white rectangles.

local MenuRenderSystem = { name = "menuRender" }
local ImageManager = require("src.graphics.ImageManager")

local ICON = 48 -- icon side, px (small-UI 32px grid rounds up to 48 here)
local ICON_PADDING = 6

local ICON_PATHS = {
    study = "assets/estudiar.png",
    hobbies = "assets/pasatiempos.png",
    communication = "assets/comunicacion.png",
    emotional_intelligence = "assets/inteligenciaEmocional.png",
    charisma = "assets/carisma.png",
}

-- per-option placeholder colors; anything unlisted renders gray
local COLORS = {
    study = { 0.35, 0.55, 0.95 },
    hobbies = { 0.45, 0.85, 0.55 },
    communication = { 0.95, 0.55, 0.75 },
    emotional_intelligence = { 0.75, 0.68, 0.95 },
    charisma = { 0.95, 0.73, 0.30 },
}

local LABELS = {
    study = "Estudiar",
    hobbies = "Pasatiempos",
    communication = "Aprender de la comunicación efectiva",
    emotional_intelligence = "Aprender de la inteligencia emocional",
    charisma = "Practicar carisma",
}

local ICONS = {
    study = "E",
    hobbies = "H",
    communication = "CO",
    emotional_intelligence = "IE",
    charisma = "CA",
}

local icons, labelFont

function MenuRenderSystem.setup(scene)
    icons = {}
    for option, path in pairs(ICON_PATHS) do
        local image = ImageManager.load(path)
        -- These are smooth 512px pictograms, so scale them with linear
        -- filtering instead of the nearest filtering used for pixel sprites.
        image:setFilter("linear", "linear")
        icons[option] = image
    end
    labelFont = love.graphics.newFont(14)
end

function MenuRenderSystem.unload(scene)
    -- drop the references, the GC collects them; never release() fonts
    -- (love.graphics may still hold one as its CURRENT font)
    icons, labelFont = nil, nil
end

function MenuRenderSystem.draw(scene)
    for _, pos, menu in scene.registry:each("position", "menu") do
        for i, option in ipairs(menu.options) do
            local x = pos.x + (i - 1) * menu.spacing
            local selected = (i == menu.cursor)

            -- the icon: full color when selected, dimmed otherwise
            local color = COLORS[option] or { 0.6, 0.6, 0.6 }
            local dim = selected and 1 or 0.45
            love.graphics.setColor(color[1] * dim, color[2] * dim, color[3] * dim)
            love.graphics.rectangle("fill", x, pos.y, ICON, ICON, 4, 4)

            local image = icons[option]
            if image then
                local maxIcon = ICON - ICON_PADDING * 2
                local scale = math.min(maxIcon / image:getWidth(),
                    maxIcon / image:getHeight())
                local width, height = image:getWidth() * scale,
                    image:getHeight() * scale
                love.graphics.setColor(1, 1, 1, dim)
                love.graphics.draw(image,
                    x + (ICON - width) / 2,
                    pos.y + (ICON - height) / 2,
                    0, scale, scale)
            else
                love.graphics.setColor(0, 0, 0, 0.75)
                love.graphics.setFont(labelFont)
                love.graphics.printf(ICONS[option] or option:sub(1, 1):upper(),
                    x, pos.y + ICON / 2 - labelFont:getHeight() / 2,
                    ICON, "center")
            end

            -- the cursor: a blinking underline. It doesn't tween over —
            -- it TELEPORTS, like the genre classics; blinking is enough
            -- life for now (animation gets its own lesson).
            if selected and math.sin(love.timer.getTime() * 6) > -0.4 then
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("fill", x, pos.y + ICON + 6, ICON, 3)
            end
        end

        -- the selected option's name. This string wants to live in a
        -- real text box — that's the next lesson.
        local rowW = (#menu.options - 1) * menu.spacing + ICON
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(labelFont)
        love.graphics.printf(LABELS[menu.options[menu.cursor]] or menu.options[menu.cursor],
            pos.x, pos.y + ICON + 16, rowW, "center")
    end
    love.graphics.setColor(1, 1, 1)
end

return MenuRenderSystem
