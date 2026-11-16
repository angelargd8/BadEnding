-- Lays out a page of cards and marks the cursor. It does not know how a card
-- draws itself; the same CardRenderer can later serve packs and date hands.

local CardRenderer = require("src.cards.CardRenderer")
local ImageManager = require("src.graphics.ImageManager")

local CollectionGridRenderSystem = { name = "collectionGridRender" }

local CARD_W, CARD_H = 68, 92
local GAP_X, GAP_Y = 8, 14
local GRID_X, GRID_Y = 244, 68
local ICON_SIZE, ICON_TOP = 22, 5

local RESPONSE_ICONS = {
    obsession = "assets/obsesion.png",
    hate = "assets/odio.png",
    friendship = "assets/amistad.png",
}

local responseIcons

local COLORS = {
    cursor = { 1.00, 0.82, 0.35 },
}

function CollectionGridRenderSystem.setup(scene)
    responseIcons = {}
    for response, path in pairs(RESPONSE_ICONS) do
        responseIcons[response] = ImageManager.load(path)
    end
end

function CollectionGridRenderSystem.unload(scene)
    responseIcons = nil
end

function CollectionGridRenderSystem.draw(scene)
    local registry = scene.registry
    local collection = registry:resource("runState").collection
    local view = registry:resource("collectionView")
    local first = (view.page - 1) * view.pageSize + 1
    local last = math.min(first + view.pageSize - 1, #collection)

    for index = first, last do
        local slot = index - first
        local column = slot % view.columns
        local row = math.floor(slot / view.columns)
        local x = GRID_X + column * (CARD_W + GAP_X)
        local y = GRID_Y + row * (CARD_H + GAP_Y)
        local card = collection[index]

        local icon = responseIcons[card.responseType]
        CardRenderer.draw(card, x, y, CARD_W, CARD_H)

        -- The response icon is the card's topmost element, drawn directly
        -- over the card art without a separate frame or floating badge.
        if icon then
            local scale = math.min(ICON_SIZE / icon:getWidth(),
                ICON_SIZE / icon:getHeight())
            local width, height = icon:getWidth() * scale,
                icon:getHeight() * scale
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(icon,
                x + (CARD_W - width) / 2,
                y + ICON_TOP,
                0, scale, scale)
        end

        if index == view.selected then
            love.graphics.setColor(COLORS.cursor)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", x - 3, y - 3,
                CARD_W + 6, CARD_H + 6, 5, 5)
            love.graphics.setLineWidth(1)
        end
    end
    love.graphics.setColor(1, 1, 1)
end

return CollectionGridRenderSystem
