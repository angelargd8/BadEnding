-- Draws the Flappy Bird game entirely from rectangles and square pixels.

local Screen = require("src.Screen")

local FlappyBirdRenderSystem = { name = "flappyBirdRender" }
local titleFont, scoreFont, hintFont

local BIRD_X, BIRD_SIZE = 112, 16
local PIPE_W, PIPE_GAP = 44, 120
local FLOOR_H = 24

function FlappyBirdRenderSystem.setup(scene)
    titleFont = love.graphics.newFont(20)
    scoreFont = love.graphics.newFont(24)
    hintFont = love.graphics.newFont(10)
end

function FlappyBirdRenderSystem.unload(scene)
    titleFont, scoreFont, hintFont = nil, nil, nil
end

function FlappyBirdRenderSystem.draw(scene)
    local game = scene.registry:resource("flappyBird")

    love.graphics.clear(0.50, 0.72, 0.86, 1)

    love.graphics.setColor(0.08, 0.42, 0.22, 1)
    for _, pipe in ipairs(game.pipes) do
        local topHeight = pipe.gapY - PIPE_GAP / 2
        local bottomY = pipe.gapY + PIPE_GAP / 2
        love.graphics.rectangle("fill", pipe.x, 0, PIPE_W, topHeight)
        love.graphics.rectangle("fill", pipe.x - 4, topHeight - 12,
            PIPE_W + 8, 12)
        love.graphics.rectangle("fill", pipe.x, bottomY, PIPE_W,
            Screen.h - FLOOR_H - bottomY)
        love.graphics.rectangle("fill", pipe.x - 4, bottomY,
            PIPE_W + 8, 12)
    end

    love.graphics.setColor(0.77, 0.70, 0.38, 1)
    love.graphics.rectangle("fill", 0, Screen.h - FLOOR_H,
        Screen.w, FLOOR_H)
    love.graphics.setColor(0.48, 0.36, 0.24, 1)
    love.graphics.rectangle("fill", 0, Screen.h - FLOOR_H,
        Screen.w, 4)

    love.graphics.setColor(0.96, 0.78, 0.28, 1)
    love.graphics.rectangle("fill", BIRD_X, game.birdY, BIRD_SIZE, BIRD_SIZE)
    love.graphics.setColor(0.12, 0.10, 0.12, 1)
    love.graphics.rectangle("fill", BIRD_X + 10, game.birdY + 4, 3, 3)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(titleFont)
    love.graphics.print("FLAPPY BIRD", 20, 16)
    love.graphics.setFont(scoreFont)
    love.graphics.printf(tostring(game.score), 0, 20, Screen.w, "center")
    love.graphics.setFont(hintFont)
    love.graphics.setColor(0.10, 0.15, 0.19, 0.85)
    love.graphics.printf("ESPACIO / CLIC: ALETEAR  ·  B: VOLVER A LA CLÍNICA",
        10, Screen.h - FLOOR_H - 18, Screen.w - 20, "center")

    if game.gameOver then
        love.graphics.setColor(0.025, 0.035, 0.055, 0.84)
        love.graphics.rectangle("fill", 100, 138, Screen.w - 200, 116)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setFont(titleFont)
        love.graphics.printf("FIN DEL JUEGO", 108, 151,
            Screen.w - 216, "center")
        love.graphics.setFont(hintFont)
        love.graphics.printf("+5 INTELIGENCIA EMOCIONAL", 108, 184,
            Screen.w - 216, "center")
        love.graphics.printf("ESPACIO: REINICIAR  ·  B: VOLVER A LA CLÍNICA",
            108, 218, Screen.w - 216, "center")
    end

    love.graphics.setColor(1, 1, 1, 1)
end

return FlappyBirdRenderSystem
