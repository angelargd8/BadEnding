-- Outdoor map around Ao Koukou. Ground and path are separate tile layers:
-- the path is transparent around its autotile edge, so the grass remains
-- visible underneath it.

local TileGrid = require("src.world.TileGrid")

local MapData = {}

local COLS, ROWS = 20, 13

function MapData.build()
    local grass = TileGrid.new(COLS, ROWS)
    local paths = TileGrid.new(COLS, ROWS)

    for y = 1, ROWS do
        for x = 1, COLS do
            grass:set(x, y, "grass")
        end
    end

    -- The central sidewalk connects the home and school horizontally.
    for x = 1, COLS do
        paths:set(x, 6, "sidewalk")
        paths:set(x, 7, "sidewalk")
    end

    return {
        { grid = grass },
        { grid = paths },
    }
end

-- The eastern block continues the same sidewalk, with room to explore the
-- grassy area south of it where the clinic and cafeteria sit.
function MapData.buildEast()
    local grass = TileGrid.new(COLS, ROWS)
    local paths = TileGrid.new(COLS, ROWS)

    for y = 1, ROWS do
        for x = 1, COLS do
            grass:set(x, y, "grass")
        end
    end

    for x = 1, COLS do
        paths:set(x, 6, "sidewalk")
        paths:set(x, 7, "sidewalk")
    end

    return {
        { grid = grass },
        { grid = paths },
    }
end

return MapData
