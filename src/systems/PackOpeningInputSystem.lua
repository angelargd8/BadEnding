-- Turns keyboard input into card selection and pack-continue requests.

local PackOpeningInputSystem = { name = "packOpeningInput" }

function PackOpeningInputSystem.update(scene, dt)
    local registry = scene.registry
    local opening = registry:resource("packOpening")

    for _, event in registry:each("keyPressed") do
        if event.key == "left" or event.key == "a" then
            if opening.selected > 1 then
                opening.selected = opening.selected - 1
            end
        elseif event.key == "right" or event.key == "d" then
            if opening.selected < #opening.cards then
                opening.selected = opening.selected + 1
            end
        elseif event.key == "return" or event.key == "space" then
            if opening.ready or opening.finished then
                registry:spawn({
                    event = true,
                    packContinueRequested = {},
                })
            end
        end
    end
end

return PackOpeningInputSystem
