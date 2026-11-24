-- The quiet frame around the collection: title, divider, page count and help.
-- Cards and their details belong to separate render systems.

local Screen = require("src.Screen")
local palette = require("src.data.menu_palette")

local CollectionChromeRenderSystem = { name = "collectionChromeRender" }

local titleFont, smallFont

function CollectionChromeRenderSystem.setup(scene)
    titleFont = love.graphics.newFont(19)
    smallFont = love.graphics.newFont(10)
end

function CollectionChromeRenderSystem.unload(scene)
    titleFont, smallFont = nil, nil
end

function CollectionChromeRenderSystem.draw(scene)
    local view = scene.registry:resource("collectionView")
    local collection = scene.registry:resource("runState").collection
    local pageCount = math.max(1, math.ceil(#collection / view.pageSize))

    love.graphics.clear(palette.black)
    love.graphics.setColor(palette.red)
    love.graphics.rectangle("fill", 230, 0, Screen.w - 230, Screen.h)

    love.graphics.setColor(palette.beige)
    love.graphics.setFont(titleFont)
    love.graphics.print("RESPUESTAS", 14, 11)

    love.graphics.setFont(smallFont)
    love.graphics.setColor(palette.rose)
    love.graphics.print("lo que podrías decir", 15, 34)
    love.graphics.printf(("%02d CARTAS"):format(#collection),
        493, 17, 132, "right")

    love.graphics.setColor(palette.beige)
    love.graphics.line(14, 53, 216, 53)
    love.graphics.line(230, 53, 626, 53)

    love.graphics.setColor(palette.beige)
    love.graphics.printf(("PÁGINA %d / %d"):format(view.page, pageCount),
        476, 371, 150, "right")
    love.graphics.print("FLECHAS recorrer · INICIO/FIN saltar · C volver", 244, 371)
    love.graphics.setColor(palette.beige)
end

return CollectionChromeRenderSystem
