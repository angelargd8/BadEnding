-- Applies gravity, advances square obstacles, and checks collisions.

local FlappyBirdSystem = { name = "flappyBird" }
local MiniGameProgress = require("src.state.MiniGameProgress")

local Screen = require("src.Screen")
local BIRD_X, BIRD_SIZE = 112, 16
local PIPE_W, PIPE_GAP = 44, 120
local FLOOR_H = 24
local GRAVITY, FLAP_SPEED, PIPE_SPEED = 650, -245, 155

local function newPipe(x)
    return {
        x = x,
        gapY = love.math.random(104, Screen.h - FLOOR_H - 64),
        passed = false,
    }
end

local function newGame()
    return {
        birdY = 180,
        birdVelocity = 0,
        flapRequested = false,
        pipes = { newPipe(Screen.w + 24) },
        score = 0,
        gameOver = false,
        progressGranted = false,
    }
end

local function overlaps(a, b)
    return a.x < b.x + b.w and a.x + a.w > b.x
        and a.y < b.y + b.h and a.y + a.h > b.y
end

local function hitsPipe(game, pipe)
    local bird = { x = BIRD_X, y = game.birdY, w = BIRD_SIZE, h = BIRD_SIZE }
    local topHeight = pipe.gapY - PIPE_GAP / 2
    local bottomY = pipe.gapY + PIPE_GAP / 2
    local top = { x = pipe.x, y = 0, w = PIPE_W, h = topHeight }
    local bottom = {
        x = pipe.x, y = bottomY, w = PIPE_W,
        h = Screen.h - FLOOR_H - bottomY,
    }
    return overlaps(bird, top) or overlaps(bird, bottom)
end

function FlappyBirdSystem.setup(scene)
    local registry = scene.registry
    if not registry:resource("flappyBird") then
        registry:setResource("flappyBird", newGame())
    end
    local game = registry:resource("flappyBird")
    if game.gameOver then
        MiniGameProgress.grant(registry:resource("runState"), game,
            "emotional_intelligence")
    end
end

function FlappyBirdSystem.update(scene, dt)
    local registry = scene.registry
    for _ in registry:each("flappyRestartRequested") do
        registry:setResource("flappyBird", newGame())
    end

    if registry:first("switchRequest") then return end
    local game = registry:resource("flappyBird")
    if game.gameOver then
        MiniGameProgress.grant(registry:resource("runState"), game,
            "emotional_intelligence")
        return
    end

    if game.flapRequested then
        game.birdVelocity = FLAP_SPEED
        game.flapRequested = false
    end

    game.birdVelocity = game.birdVelocity + GRAVITY * dt
    game.birdY = game.birdY + game.birdVelocity * dt
    if game.birdY < 0 or game.birdY + BIRD_SIZE > Screen.h - FLOOR_H then
        game.gameOver = true
        MiniGameProgress.grant(registry:resource("runState"), game,
            "emotional_intelligence")
        return
    end

    for i = #game.pipes, 1, -1 do
        local pipe = game.pipes[i]
        pipe.x = pipe.x - PIPE_SPEED * dt
        if not pipe.passed and pipe.x + PIPE_W < BIRD_X then
            pipe.passed = true
            game.score = game.score + 1
        end
        if hitsPipe(game, pipe) then
            game.gameOver = true
            MiniGameProgress.grant(registry:resource("runState"), game,
                "emotional_intelligence")
            return
        end
        if pipe.x + PIPE_W < 0 then
            table.remove(game.pipes, i)
        end
    end

    local lastPipe = game.pipes[#game.pipes]
    if not lastPipe or lastPipe.x < Screen.w - 220 then
        game.pipes[#game.pipes + 1] = newPipe(Screen.w + 24)
    end
end

return FlappyBirdSystem
