-- Reveals text a few characters per second. During a vignette, Enter
-- completes the current line; it does not affect the confirm key that
-- selected the activity because that frame also contains activityPicked.

local TextboxSystem = { name = "textbox" }

function TextboxSystem.update(scene, dt)
    local registry = scene.registry
    local day = registry:resource("dayloop")
    local canSkip = day and day.phase == "vignette"
        and not registry:first("activityPicked")

    if canSkip then
        for _, keyPressed in registry:each("keyPressed") do
            if keyPressed.key == "return" then
                for _, textbox in registry:each("textbox") do
                    textbox.visibleChars = #textbox.text
                end
                return
            end
        end
    end

    for _, textbox in registry:each("textbox") do
        textbox.visibleChars = math.min(
            textbox.visibleChars + textbox.speed * dt,
            #textbox.text)
    end
end

return TextboxSystem
