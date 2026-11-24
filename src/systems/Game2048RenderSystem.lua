-- Draws the 2048 board and feedback using shapes and text only.

local Screen = require("src.Screen")

local Game2048RenderSystem = { name = "game2048Render" }
local titleFont, tileFont, smallFont

local SIZE = 4
local TILE = 68
local GAP = 8
local BOARD = SIZE * TILE + (SIZE + 1) * GAP
local BOARD_X = math.floor((Screen.w - BOARD) / 2)
local BOARD_Y = 66

local COLORS = {
    [0] = { 0.12, 0.14, 0.17 },
    [2] = { 0.91, 0.87, 0.80 },
    [4] = { 0.91, 0.80, 0.63 },
    [8] = { 0.91, 0.62, 0.39 },
    [16] = { 0.89, 0.45, 0.34 },
    [32] = { 0.84, 0.31, 0.27 },
    [64] = { 0.75, 0.20, 0.20 },
    [128] = { 0.91, 0.76, 0.42 },
    [256] = { 0.91, 0.70, 0.31 },
    [512] = { 0.90, 0.61, 0.21 },
    [1024] = { 0.84, 0.49, 0.18 },
    [2048] = { 0.86, 0.37, 0.12 },
}

function Game2048RenderSystem.setup(scene)
    titleFont = love.graphics.newFont(25)
    tileFont = love.graphics.newFont(24)
    smallFont = love.graphics.newFont(11)
end

function Game2048RenderSystem.unload(scene)
    titleFont, tileFont, smallFont = nil, nil, nil
end

function Game2048RenderSystem.draw(scene)
    local game = scene.registry:resource("game2048")
    love.graphics.clear(0.055, 0.065, 0.105, 1)

    love.graphics.setColor(0.96, 0.91, 0.82, 1)
    love.graphics.setFont(titleFont)
    love.graphics.print("2048", BOARD_X, 16)
    love.graphics.setFont(smallFont)
    love.graphics.printf(("PUNTOS  %d"):format(game.score),
        BOARD_X, 35, BOARD, "right")

    love.graphics.setColor(0.16, 0.18, 0.22, 1)
    love.graphics.rectangle("fill", BOARD_X, BOARD_Y, BOARD, BOARD, 8, 8)

    for row = 1, SIZE do
        for col = 1, SIZE do
            local value = game.grid[row][col]
            local x = BOARD_X + GAP + (col - 1) * (TILE + GAP)
            local y = BOARD_Y + GAP + (row - 1) * (TILE + GAP)
            local color = COLORS[value] or { 0.58, 0.30, 0.55 }

            love.graphics.setColor(color[1], color[2], color[3], 1)
            love.graphics.rectangle("fill", x, y, TILE, TILE, 5, 5)
            if value > 0 then
                local textColor = value <= 4 and { 0.24, 0.22, 0.20 }
                    or { 1, 0.97, 0.91 }
                love.graphics.setColor(textColor[1], textColor[2], textColor[3], 1)
                love.graphics.setFont(value >= 1024 and smallFont or tileFont)
                love.graphics.printf(tostring(value), x, y + 20, TILE, "center")
            end
        end
    end

    love.graphics.setColor(0.92, 0.90, 0.84, 0.78)
    love.graphics.setFont(smallFont)
    love.graphics.printf("FLECHAS / WASD: MOVER | R: REINICIAR | B: VOLVER AL AULA",
        12, Screen.h - 18, Screen.w - 24, "center")

    if game.gameOver or game.waitingAfterWin then
        love.graphics.setColor(0.025, 0.035, 0.055, 0.86)
        love.graphics.rectangle("fill", BOARD_X + 12, BOARD_Y + 112,
            BOARD - 24, 100, 6, 6)
        love.graphics.setColor(0.97, 0.92, 0.83, 1)
        love.graphics.setFont(titleFont)
        local message = game.won and "2048 CONSEGUIDO" or "FIN DEL JUEGO"
        love.graphics.printf(message, BOARD_X + 18, BOARD_Y + 124,
            BOARD - 36, "center")
        love.graphics.setFont(smallFont)
        love.graphics.printf("+5 NIVEL DE ESTUDIO", BOARD_X + 18,
            BOARD_Y + 153, BOARD - 36, "center")
        local hint = game.waitingAfterWin and "ENTER: SEGUIR JUGANDO"
            or "R: REINICIAR | B: VOLVER AL AULA"
        love.graphics.printf(hint, BOARD_X + 18, BOARD_Y + 179,
            BOARD - 36, "center")
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return Game2048RenderSystem
