-- Persists the ending and returns to the title menu on confirmation.

local SaveFile = require("src.state.SaveFile")
local EndingRules = require("src.state.EndingRules")

local EndingInputSystem = { name = "endingInput" }

function EndingInputSystem.setup(scene)
    local registry = scene.registry
    local ending = registry:resource("ending")
    local runState = registry:resource("runState")
    if type(ending.result) ~= "table" or ending.result.happinessMet == nil then
        ending.result = EndingRules.evaluate(runState)
    end
    SaveFile.save({
        runState = runState,
        scene = "ending",
        payload = { result = ending.result },
    })
end

function EndingInputSystem.update(scene)
    local registry = scene.registry
    for _, key in registry:each("keyPressed") do
        if key.key == "space" or key.key == "return" then
            registry:spawn({ switchRequest = { to = "mainMenu" } })
            return
        end
    end
    for _, mouse in registry:each("mousePressed") do
        if mouse.button == 1 then
            registry:spawn({ switchRequest = { to = "mainMenu" } })
            return
        end
    end
end

return EndingInputSystem
