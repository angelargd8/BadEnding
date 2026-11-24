-- Draws the map's terrain grid below the character. The grid only says
-- "grass"; AutoTile turns each cell's four neighbor relationships into the
-- tileset quad that makes its edges join correctly.

local AutoTile = require("src.world.AutoTile")
local Screen = require("src.Screen")
local ImageManager = require("src.graphics.ImageManager")

local TilemapRenderSystem = { name = "tilemapRender" }

local SOURCE_CELL = AutoTile.CELL
local void = { 0.07, 0.08, 0.11 }
local SHEETS = {
    grass = "assets/grass_tiles.png",
    sidewalk = "assets/sidewalk_tiles.png",
    cafeteriaFloor = "assets/cafeteria_floor_tiles.png",
}
local SOLID_FLOORS = {
    -- The home uses a light, uninterrupted wood tone; the clinic stays cool.
    wood = { 0.86, 0.72, 0.52 },
    schoolFloor = { 0.68, 0.74, 0.80 },
}

function TilemapRenderSystem.draw(scene)
    love.graphics.setColor(void)
    love.graphics.rectangle("fill", 0, 0, Screen.w, Screen.h)

    local _, tilemap = scene.registry:first("tilemap")
    local scale = tilemap.cell / SOURCE_CELL

    love.graphics.setColor(1, 1, 1)
    for _, layer in ipairs(tilemap.layers) do
        local grid = layer.grid
        for x, y, terrain in grid:each() do
            local drawX = tilemap.ox + (x - 1) * tilemap.cell
            local drawY = tilemap.oy + (y - 1) * tilemap.cell
            local solidColor = SOLID_FLOORS[terrain]

            if solidColor then
                love.graphics.setColor(solidColor)
                love.graphics.rectangle("fill", drawX, drawY,
                    tilemap.cell, tilemap.cell)
            else
                local path = SHEETS[terrain]
                assert(path, "no tileset for terrain: " .. tostring(terrain))
                local sheet = ImageManager.sheet(path, SOURCE_CELL, SOURCE_CELL)
                -- Grass and sidewalk use neighbor masks to select connected
                -- edge art. Other terrain repeats its full tile.
                local mask = 15
                if terrain == "grass" or terrain == "sidewalk" then
                    mask = AutoTile.maskAt(grid, x, y)
                end
                local col, row = AutoTile.quadCell(mask)
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(
                    sheet.image,
                    sheet:quad(col, row),
                    drawX,
                    drawY,
                    0, scale, scale
                )
            end
        end
    end
end

return TilemapRenderSystem
