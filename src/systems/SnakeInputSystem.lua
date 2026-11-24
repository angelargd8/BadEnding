-- Turns key presses into snake direction, restart, and return requests.

local SnakeInputSystem = { name = "snakeInput" }
local MiniGameFlow = require("src.state.MiniGameFlow")
local DIRECTIONS = {
    up = { x = 0, y = -1 }, w = { x = 0, y = -1 },
    down = { x = 0, y = 1 }, s = { x = 0, y = 1 },
    left = { x = -1, y = 0 }, a = { x = -1, y = 0 },
    right = { x = 1, y = 0 }, d = { x = 1, y = 0 },
}

function SnakeInputSystem.update(scene)
    local registry = scene.registry
    local snake = registry:resource("snake")

    for _, key in registry:each("keyPressed") do
        if key.key == "b" or key.key == "backspace" then
            registry:spawn({
                switchRequest = MiniGameFlow.returnRequest(
                    registry:resource("runState"),
                    "homeInterior", { x = 400, y = 210 }),
            })
            return
        elseif key.key == "r" or (snake.gameOver
                and (key.key == "return" or key.key == "space")) then
            registry:spawn({ event = true, snakeRestartRequested = {} })
        else
            local direction = DIRECTIONS[key.key]
            if direction and not snake.gameOver and not snake.nextDirection
                    and not (direction.x == -snake.direction.x
                        and direction.y == -snake.direction.y) then
                snake.nextDirection = direction
            end
        end
    end
end

return SnakeInputSystem
