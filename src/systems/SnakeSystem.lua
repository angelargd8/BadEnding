-- Advances the snake on a fixed grid and handles food and collisions.

local SnakeSystem = { name = "snake" }
local MiniGameProgress = require("src.state.MiniGameProgress")

local COLS, ROWS = 28, 14
local STEP_TIME = 0.14

local function placeFood(state)
    local free = {}
    for y = 1, ROWS do
        for x = 1, COLS do
            local occupied = false
            for _, part in ipairs(state.parts) do
                if part.x == x and part.y == y then
                    occupied = true
                    break
                end
            end
            if not occupied then
                free[#free + 1] = { x = x, y = y }
            end
        end
    end
    if #free == 0 then
        state.won = true
        state.gameOver = true
        state.food = nil
        return
    end
    state.food = free[love.math.random(1, #free)]
end

local function newGame()
    local state = {
        parts = {
            { x = 14, y = 7 },
            { x = 13, y = 7 },
            { x = 12, y = 7 },
        },
        direction = { x = 1, y = 0 },
        nextDirection = nil,
        score = 0,
        timer = 0,
        gameOver = false,
        won = false,
        progressGranted = false,
    }
    placeFood(state)
    return state
end

local function sameCell(a, b)
    return a.x == b.x and a.y == b.y
end

local function step(state)
    if state.nextDirection then
        state.direction = state.nextDirection
        state.nextDirection = nil
    end

    local head = state.parts[1]
    local nextHead = {
        x = head.x + state.direction.x,
        y = head.y + state.direction.y,
    }
    local eats = state.food and sameCell(nextHead, state.food)

    if nextHead.x < 1 or nextHead.x > COLS
            or nextHead.y < 1 or nextHead.y > ROWS then
        state.gameOver = true
        return
    end

    for i, part in ipairs(state.parts) do
        -- The tail moves away on a normal step, so it is a legal next cell.
        if (eats or i < #state.parts) and sameCell(nextHead, part) then
            state.gameOver = true
            return
        end
    end

    table.insert(state.parts, 1, nextHead)
    if eats then
        state.score = state.score + 1
        placeFood(state)
    else
        table.remove(state.parts)
    end
end

function SnakeSystem.setup(scene)
    local registry = scene.registry
    if not registry:resource("snake") then
        registry:setResource("snake", newGame())
    end
    local snake = registry:resource("snake")
    if snake.gameOver then
        MiniGameProgress.grant(registry:resource("runState"), snake, "hobbies")
    end
end

function SnakeSystem.update(scene, dt)
    local registry = scene.registry
    for _ in registry:each("snakeRestartRequested") do
        registry:setResource("snake", newGame())
    end

    if registry:first("switchRequest") then return end
    local snake = registry:resource("snake")
    if snake.gameOver then
        MiniGameProgress.grant(registry:resource("runState"), snake, "hobbies")
        return
    end

    snake.timer = snake.timer + dt
    while snake.timer >= STEP_TIME and not snake.gameOver do
        snake.timer = snake.timer - STEP_TIME
        step(snake)
    end
    if snake.gameOver then
        MiniGameProgress.grant(registry:resource("runState"), snake, "hobbies")
    end
end

return SnakeSystem
