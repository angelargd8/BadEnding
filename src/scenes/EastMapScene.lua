-- Eastern block: the school and cafeteria sit above the sidewalk, with
-- trees and flowers on the grass below it.

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

local function spawnBuilding(registry, path, x, y, door)
    registry:spawn({
        position = { x = x, y = y },
        sprite = {
            path = path, w = 128, h = 128,
            frame = 1, row = 1, scale = 1,
        },
    })

    local solids = {
        { x = 0, y = 0, w = 128, h = 88 },
        { x = 0, y = 88, w = door.left, h = 40 },
        { x = door.right, y = 88, w = 128 - door.right, h = 40 },
    }
    for _, solid in ipairs(solids) do
        registry:spawn({ position = { x = x, y = y }, solid = solid })
    end
end

local function spawnFlower(registry, frame, x, y)
    registry:spawn({
        position = { x = x, y = y },
        sprite = {
            path = PROP_SHEET, w = 32, h = 32,
            frame = frame, row = 2, scale = 1,
        },
    })
end

local function spawnTree(registry, frame, x, y)
    registry:spawn({
        position = { x = x, y = y },
        solid = { x = 20, y = 36, w = 24, h = 24 },
        sprite = {
            path = PROP_SHEET, w = 32, h = 32,
            frame = frame, row = 1, scale = 2,
        },
    })
end

return function(payload)
    payload = payload or {}
    local scene = Scene.new("eastMap")
    local registry = scene.registry

    registry:setResource("map", {
        speed = 150,
        normalize = true,
    })

    registry:spawn({
        tilemap = {
            layers = MapData.buildEast(),
            cell = 32,
            cols = 20,
            rows = 13,
            ox = 0,
            oy = 0,
        },
    })

    -- The clinic and cafeteria sit above the sidewalk; each doorway leads
    -- to a separate interior map. Grass and plants fill the area below.
    spawnBuilding(registry, "assets/japanese_clinic.png", 112, 32,
        { left = 48, right = 80 })
    spawnBuilding(registry, "assets/cafe_building.png", 384, 32,
        { left = 44, right = 84 })

    registry:spawn({
        position = { x = 160, y = 132 },
        exitTrigger = {
            w = 32, h = 36, to = "clinicInterior",
            enterX = 288, enterY = 288,
        },
    })
    registry:spawn({
        position = { x = 428, y = 132 },
        exitTrigger = {
            w = 40, h = 36,
            to = "cafeInterior",
            enterX = 288, enterY = 288,
        },
    })

    spawnTree(registry, 1, 32, 226)
    spawnTree(registry, 2, 544, 226)
    spawnFlower(registry, 1, 64, 332)
    spawnFlower(registry, 2, 320, 336)
    spawnFlower(registry, 3, 552, 332)
    spawnFlower(registry, 1, 176, 264)
    spawnFlower(registry, 2, 256, 352)
    spawnFlower(registry, 1, 400, 264)
    spawnFlower(registry, 2, 472, 352)
    spawnFlower(registry, 1, 100, 300)
    spawnFlower(registry, 2, 200, 320)
    spawnFlower(registry, 1, 280, 260)
    spawnFlower(registry, 2, 360, 300)
    spawnFlower(registry, 1, 480, 280)
    spawnFlower(registry, 2, 520, 360)

    -- The west edge returns to the main map. The arrival point there is
    -- safely inside the map, away from its east exit trigger.
    registry:spawn({
        position = { x = 0, y = 160 },
        exitTrigger = {
            w = 32, h = 64, to = "map", enterX = 520, enterY = 176,
        },
    })

    registry:spawn({
        position = {
            x = payload.x or 16,
            y = payload.y or 176,
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
