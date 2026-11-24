-- Builds small place-specific interiors from shared map systems and data.

local Scene = require("src.ecs.Scene")
local SpriteClip = require("src.anim.SpriteClip")
local TileGrid = require("src.world.TileGrid")

local MapInputSystem = require("src.systems.MapInputSystem")
local MovementSystem = require("src.systems.MovementSystem")
local MapCollisionSystem = require("src.systems.MapCollisionSystem")
local LocationRewardSystem = require("src.systems.LocationRewardSystem")
local MapExitSystem = require("src.systems.MapExitSystem")
local SpriteFacingSystem = require("src.systems.SpriteFacingSystem")
local SpriteAnimationSystem = require("src.systems.SpriteAnimationSystem")
local TilemapRenderSystem = require("src.systems.TilemapRenderSystem")
local SpriteRenderSystem = require("src.systems.SpriteRenderSystem")
local WorldDateRenderSystem = require("src.systems.WorldDateRenderSystem")

local PLAYER_SHEET = "assets/lab_walk.png"
local PROP_SHEET = "assets/map_props.png"
local COLS, ROWS = 20, 13

local function buildFloor(terrain)
    local grid = TileGrid.new(COLS, ROWS)
    for y = 1, ROWS do
        for x = 1, COLS do
            grid:set(x, y, terrain)
        end
    end
    return { { grid = grid } }
end

local function spawnFurniture(registry, item)
    local scale = item.scale or 1
    local solid
    if item.solid then
        solid = {
            x = item.solid.x * scale,
            y = item.solid.y * scale,
            w = item.solid.w * scale,
            h = item.solid.h * scale,
        }
    end

    registry:spawn({
        position = { x = item.x, y = item.y },
        solid = solid,
        sprite = {
            path = item.path or PROP_SHEET,
            w = item.w or 32,
            h = item.h or 32,
            frame = item.frame,
            row = item.row,
            scale = scale,
        },
    })
end

local function makePlayer(registry, payload)
    registry:spawn({
        position = {
            x = payload.x or 288,
            y = payload.y or 288,
        },
        body = { x = 20, y = 40, w = 24, h = 24 },
        moveIntent = { dx = 0, dy = 0 },
        velocity = { x = 0, y = 0 },
        sprite = {
            path = PLAYER_SHEET, w = 32, h = 32,
            frame = 1, row = 1, scale = 2,
        },
        clipAnim = {
            clip = SpriteClip.new(4, 0.5),
            t = 0, playing = false, idle = 1,
        },
    })
end

local InteriorScene = {}

function InteriorScene.new(config)
    return function(payload)
        payload = payload or {}
        local scene = Scene.new(config.name)
        local registry = scene.registry

        registry:setResource("map", { speed = 150, normalize = true })
        registry:spawn({
            tilemap = {
                layers = buildFloor(config.floor),
                cell = 32,
                cols = COLS,
                rows = ROWS,
                ox = 0,
                oy = 0,
            },
        })

        for _, item in ipairs(config.furniture or {}) do
            spawnFurniture(registry, item)
        end

        for _, trigger in ipairs(config.triggers or {}) do
            registry:spawn({
                position = { x = trigger.x, y = trigger.y },
                exitTrigger = {
                    w = trigger.w,
                    h = trigger.h,
                    to = trigger.to,
                    enterX = trigger.enterX,
                    enterY = trigger.enterY,
                },
            })
        end

        for _, reward in ipairs(config.rewardTriggers or {}) do
            registry:spawn({
                position = { x = reward.x, y = reward.y },
                locationReward = {
                    key = reward.key,
                    activity = reward.activity,
                    relationship = reward.relationship,
                    w = reward.w,
                    h = reward.h,
                    to = reward.to,
                    toByDay = reward.toByDay,
                    enterX = reward.enterX,
                    enterY = reward.enterY,
                },
            })
        end

        -- Walk to the south edge to leave and return to this building's
        -- exterior doorway.
        registry:spawn({
            position = { x = 288, y = 368 },
            exitTrigger = {
                w = 64, h = 32,
                to = config.returnTo,
                enterX = config.returnX,
                enterY = 224,
                timeOfDay = config.exitTimeOfDay,
                timeDay = config.exitTimeDay,
            },
        })

        makePlayer(registry, payload)

        scene:addSystem(MapInputSystem)
        scene:addSystem(MovementSystem)
        scene:addSystem(MapCollisionSystem)
        scene:addSystem(LocationRewardSystem)
        scene:addSystem(MapExitSystem)
        scene:addSystem(SpriteFacingSystem)
        scene:addSystem(SpriteAnimationSystem)
        scene:addSystem(TilemapRenderSystem)
        scene:addSystem(SpriteRenderSystem)
        scene:addSystem(WorldDateRenderSystem)
        return scene
    end
end

return InteriorScene
