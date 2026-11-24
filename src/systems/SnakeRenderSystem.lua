-- Draws the snake board, food, score, and controls.

local Screen = require("src.Screen")

local SnakeRenderSystem = { name = "snakeRender" }
local titleFont, bodyFont, hintFont

local CELL, COLS, ROWS = 20, 28, 14
local BOARD_X, BOARD_Y = 40, 74

function SnakeRenderSystem.setup(scene)
    titleFont = love.graphics.newFont(20)
    bodyFont = love.graphics.newFont(13)
    hintFont = love.graphics.newFont(10)
end

function SnakeRenderSystem.unload(scene)
    titleFont, bodyFont, hintFont = nil, nil, nil
end

local function drawCell(x, y, color, inset)
    love.graphics.setColor(color[1], color[2], color[3], color[4] or 1)
    love.graphics.rectangle("fill",
        BOARD_X + (x - 1) * CELL + inset,
        BOARD_Y + (y - 1) * CELL + inset,
        CELL - inset * 2, CELL - inset * 2, 3, 3)
end

function SnakeRenderSystem.draw(scene)
    local snake = scene.registry:resource("snake")

    love.graphics.clear(0.055, 0.065, 0.105, 1)
    love.graphics.setColor(0.94, 0.89, 0.76, 1)
    love.graphics.setFont(titleFont)
    love.graphics.print("SNAKE", BOARD_X, 23)
    love.graphics.setFont(bodyFont)
    love.graphics.printf(("PUNTOS  %d"):format(snake.score),
        BOARD_X, 28, CELL * COLS, "right")

    love.graphics.setColor(0.13, 0.15, 0.19, 1)
    love.graphics.rectangle("fill", BOARD_X - 4, BOARD_Y - 4,
        CELL * COLS + 8, CELL * ROWS + 8, 4, 4)
    love.graphics.setColor(0.085, 0.10, 0.13, 1)
    love.graphics.rectangle("fill", BOARD_X, BOARD_Y, CELL * COLS, CELL * ROWS)

    love.graphics.setColor(0.11, 0.13, 0.16, 1)
    for x = 1, COLS - 1 do
        love.graphics.line(BOARD_X + x * CELL, BOARD_Y,
            BOARD_X + x * CELL, BOARD_Y + ROWS * CELL)
    end
    for y = 1, ROWS - 1 do
        love.graphics.line(BOARD_X, BOARD_Y + y * CELL,
            BOARD_X + COLS * CELL, BOARD_Y + y * CELL)
    end

    if snake.food then
        drawCell(snake.food.x, snake.food.y, { 0.92, 0.39, 0.38, 1 }, 3)
    end
    for i, part in ipairs(snake.parts) do
        local green = i == 1 and { 0.72, 0.84, 0.39, 1 }
            or { 0.40, 0.68, 0.36, 1 }
        drawCell(part.x, part.y, green, 2)
    end

    love.graphics.setColor(1, 1, 1, 0.72)
    love.graphics.setFont(hintFont)
    love.graphics.printf("FLECHAS / WASD: MOVER  ·  B: VOLVER A CASA",
        20, 366, Screen.w - 40, "center")

    if snake.gameOver then
        love.graphics.setColor(0.025, 0.035, 0.055, 0.84)
        love.graphics.rectangle("fill", BOARD_X, BOARD_Y + 94,
            CELL * COLS, 100)
        love.graphics.setColor(0.96, 0.91, 0.82, 1)
        love.graphics.setFont(titleFont)
        local result = snake.won and "¡GANASTE!" or "FIN DEL JUEGO"
        love.graphics.printf(result,
            BOARD_X, BOARD_Y + 106, CELL * COLS, "center")
        love.graphics.setFont(hintFont)
        love.graphics.printf("+5 FELICIDAD / PASATIEMPOS",
            BOARD_X, BOARD_Y + 136, CELL * COLS, "center")
        love.graphics.printf("R o ENTER: REINICIAR  ·  B: VOLVER A CASA",
            BOARD_X, BOARD_Y + 161, CELL * COLS, "center")
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return SnakeRenderSystem
