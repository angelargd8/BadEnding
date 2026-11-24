-- Turns key presses into moves, restart requests, and a return to the school.

local Game2048InputSystem = { name = "game2048Input" }
local MiniGameFlow = require("src.state.MiniGameFlow")

local DIRECTIONS = {
    up = "up", w = "up",
    down = "down", s = "down",
    left = "left", a = "left",
    right = "right", d = "right",
}

function Game2048InputSystem.update(scene)
    local registry = scene.registry
    local game = registry:resource("game2048")

    for _, key in registry:each("keyPressed") do
        if key.key == "b" or key.key == "backspace" then
            registry:spawn({
                switchRequest = MiniGameFlow.returnRequest(
                    registry:resource("runState"),
                    "schoolInterior", { x = 288, y = 288 }),
            })
            return
        elseif key.key == "r" then
            game.restartRequested = true
        elseif key.key == "return" and game.waitingAfterWin then
            game.waitingAfterWin = false
        else
            local direction = DIRECTIONS[key.key]
            if direction and not game.gameOver and not game.waitingAfterWin then
                game.moveRequested = direction
            end
        end
    end
end

return Game2048InputSystem
