-- Turns overlap with a map exit into a deferred scene-switch request.
-- Game performs the switch after this scene's update has finished.

local MapExitSystem = { name = "mapExit" }

local function overlaps(a, b)
    return a.x < b.x + b.w and a.x + a.w > b.x
        and a.y < b.y + b.h and a.y + a.h > b.y
end

function MapExitSystem.update(scene)
    local registry = scene.registry
    if registry:first("switchRequest") then return end

    for _, exitPos, exit in registry:each("position", "exitTrigger") do
        for _, playerPos, body in registry:each("position", "body") do
            local player = {
                x = playerPos.x + (body.x or 0),
                y = playerPos.y + (body.y or 0),
                w = body.w,
                h = body.h,
            }
            local trigger = {
                x = exitPos.x, y = exitPos.y,
                w = exit.w, h = exit.h,
            }

            if overlaps(player, trigger) then
                local runState = registry:resource("runState")
                local target = exit.to
                if exit.toByDay and runState then
                    target = exit.toByDay[runState.day] or target
                end
                if exit.timeOfDay and runState
                        and (not exit.timeDay or runState.day == exit.timeDay) then
                    runState.timeOfDay = exit.timeOfDay
                end

                registry:spawn({
                    switchRequest = {
                        to = target,
                        payload = {
                            x = exit.enterX or 16,
                            y = exit.enterY or playerPos.y,
                        },
                    },
                })
                return
            end
        end
    end
end

return MapExitSystem
