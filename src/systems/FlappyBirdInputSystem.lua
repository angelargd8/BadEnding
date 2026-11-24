-- Converts key and mouse presses into flap, restart, and return requests.

local FlappyBirdInputSystem = { name = "flappyBirdInput" }
local MiniGameFlow = require("src.state.MiniGameFlow")

function FlappyBirdInputSystem.update(scene)
    local registry = scene.registry
    local game = registry:resource("flappyBird")

    for _, key in registry:each("keyPressed") do
        if key.key == "b" or key.key == "backspace" then
            registry:spawn({
                switchRequest = MiniGameFlow.returnRequest(
                    registry:resource("runState"),
                    "clinicInterior", { x = 288, y = 288 }),
            })
            return
        elseif game.gameOver and (key.key == "space"
                or key.key == "return" or key.key == "r") then
            registry:spawn({ event = true, flappyRestartRequested = {} })
        elseif not game.gameOver and (key.key == "space"
                or key.key == "up" or key.key == "w") then
            game.flapRequested = true
        end
    end

    if game.gameOver then return end
    for _, mouse in registry:each("mousePressed") do
        if mouse.button == 1 then
            game.flapRequested = true
            break
        end
    end
end

return FlappyBirdInputSystem
