-- The central block around Ao Koukou: home and school share a sidewalk
-- that continues east into the next map.

local Scene = require("src.ecs.Scene")
local SpriteClip = require("src.anim.SpriteClip")
local MapData = require("src.data.map")

local MapInputSystem = require("src.systems.MapInputSystem")
local MovementSystem = require("src.systems.MovementSystem")
local MapCollisionSystem = require("src.systems.MapCollisionSystem")
local MapExitSystem = require("src.systems.MapExitSystem")
local SpriteFacingSystem = require("src.systems.SpriteFacingSystem")
local SpriteAnimationSystem = require("src.systems.SpriteAnimationSystem")
local TilemapRenderSystem = require("src.systems.TilemapRenderSystem")
local SpriteRenderSystem = require("src.systems.SpriteRenderSystem")
local WorldDateRenderSystem = require("src.systems.WorldDateRenderSystem")

local PLAYER_SHEET = "assets/lab_walk.png"
local PROP_SHEET = "assets/map_props.png"
local PLAYER_SCALE = 2

local function spawnBuilding(registry, path, x, door, scale, y)
    scale = scale or 1
    y = y or 0
    registry:spawn({
        position = { x = x, y = y },
        sprite = {
            path = path, w = 128, h = 128,
            frame = 1, row = 1, scale = scale,
        },
    })

    local solids
    if door then
        solids = {
            { x = 0, y = 0, w = 128, h = 88 },
            { x = 0, y = 88, w = door.left, h = 40 },
            { x = door.right, y = 88, w = 128 - door.right, h = 40 },
        }
    else
        solids = { { x = 0, y = 0, w = 128, h = 128 } }
    end

    for _, solid in ipairs(solids) do
        registry:spawn({
            position = { x = x, y = y },
            solid = {
                x = solid.x * scale,
                y = solid.y * scale,
                w = solid.w * scale,
                h = solid.h * scale,
            },
        })
    end
end

local function spawnProp(registry, frame, row, x, y, scale, solid)
    registry:spawn({
        position = { x = x, y = y },
        solid = solid,
        sprite = {
            path = PROP_SHEET, w = 32, h = 32,
            frame = frame, row = row, scale = scale or 1,
        },
    })
end

return function(payload)
    local scene = Scene.new("map")
    local registry = scene.registry

    registry:setResource("map", {
        speed = 150,
        normalize = true,
    })

    registry:spawn({
        tilemap = {
            layers = MapData.build(),
            cell = 32,
            cols = 20,
            rows = 13,
            ox = 0,
            oy = 0,
        },
    })

    -- The central map keeps only the home and school.
    spawnBuilding(registry, "assets/japanese_house.png", 12,
        { left = 42, right = 82 }, nil, 32)
    spawnBuilding(registry, "assets/school_building.png", 454,
        { left = 44, right = 84 }, 1.25)

    -- The house's open doorway enters its own interior map.
    registry:spawn({
        position = { x = 54, y = 132 },
        exitTrigger = {
            w = 40, h = 36, to = "homeInterior",
            enterX = 288, enterY = 288,
        },
    })

    registry:spawn({
        position = { x = 514, y = 118 },
        exitTrigger = {
            w = 44, h = 42, to = "schoolInterior",
            enterX = 288, enterY = 288,
        },
    })

    -- The east end of the sidewalk leads to the clinic/cafeteria block.
    registry:spawn({
        position = { x = 608, y = 160 },
        exitTrigger = { w = 32, h = 64, to = "eastMap", enterX = 64, enterY = 176 },
    })

    -- A few simple landmarks on the grass beside the path.
    spawnProp(registry, 1, 1, 96, 248, 2,
        { x = 20, y = 36, w = 24, h = 24 })
    spawnProp(registry, 2, 1, 552, 226, 2,
        { x = 20, y = 36, w = 24, h = 24 })
    spawnProp(registry, 1, 2, 164, 258, 1)
    spawnProp(registry, 2, 2, 430, 258, 1)
    spawnProp(registry, 1, 2, 196, 300, 1)
    spawnProp(registry, 2, 2, 220, 356, 1)
    spawnProp(registry, 1, 2, 396, 310, 1)
    spawnProp(registry, 2, 2, 460, 356, 1)
    spawnProp(registry, 1, 2, 548, 278, 1)
    spawnProp(registry, 2, 2, 184, 72, 1)
    spawnProp(registry, 1, 2, 292, 96, 1)
    spawnProp(registry, 2, 2, 384, 72, 1)
    spawnProp(registry, 1, 2, 32, 356, 1)
    spawnProp(registry, 2, 2, 248, 300, 1)
    spawnProp(registry, 1, 2, 380, 360, 1)
    spawnProp(registry, 2, 2, 520, 360, 1)
    spawnProp(registry, 1, 2, 580, 300, 1)
    spawnProp(registry, 3, 2, 112, 320, 1)
    spawnProp(registry, 4, 2, 500, 320, 1)

    registry:spawn({
        position = {
            x = (payload and payload.x) or 288,
            y = (payload and payload.y) or 260,
        },
        body = { x = 20, y = 40, w = 24, h = 24 },
        moveIntent = { dx = 0, dy = 0 },
        velocity = { x = 0, y = 0 },
        sprite = {
            path = PLAYER_SHEET, w = 32, h = 32,
            frame = 1, row = 1, scale = PLAYER_SCALE,
        },
        clipAnim = {
            clip = SpriteClip.new(4, 0.5),
            t = 0, playing = false, idle = 1,
        },
    })

    scene:addSystem(MapInputSystem)
    scene:addSystem(MovementSystem)
    scene:addSystem(MapCollisionSystem)
    scene:addSystem(MapExitSystem)
    scene:addSystem(SpriteFacingSystem)
    scene:addSystem(SpriteAnimationSystem)
    scene:addSystem(TilemapRenderSystem)
    scene:addSystem(SpriteRenderSystem)
    scene:addSystem(WorldDateRenderSystem)
    return scene
end
