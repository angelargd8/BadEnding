-- Grants one location-specific activity reward when the player reaches it.

local activities = require("src.data.activities")
local Relationship = require("src.state.Relationship")

local LocationRewardSystem = { name = "locationReward" }

local function overlaps(a, b)
    return a.x < b.x + b.w and a.x + a.w > b.x
        and a.y < b.y + b.h and a.y + a.h > b.y
end

local function grant(runState, reward)
    local activity = activities[reward.activity]
    if not activity then return end

    if activity.stat then
        runState.stats[activity.stat] = (runState.stats[activity.stat] or 0) + 1
    end
    runState.practice[reward.activity] =
        (runState.practice[reward.activity] or 0) + 1
    runState.weekPractice[reward.activity] =
        (runState.weekPractice[reward.activity] or 0) + 1

    if reward.relationship then
        Relationship.addPoint(runState, reward.relationship)
    end
end

function LocationRewardSystem.update(scene)
    local registry = scene.registry
    if registry:first("switchRequest") then return end

    local runState = registry:resource("runState")
    if not runState then return end
    runState.rewardedLocations = runState.rewardedLocations or {}

    for _, rewardPos, reward in registry:each("position", "locationReward") do
        local rewardId = tostring(runState.week) .. ":" .. reward.key
        local trigger = {
            x = rewardPos.x, y = rewardPos.y,
            w = reward.w, h = reward.h,
        }
        for _, playerPos, body in registry:each("position", "body") do
            local player = {
                x = playerPos.x + (body.x or 0),
                y = playerPos.y + (body.y or 0),
                w = body.w, h = body.h,
            }
            if overlaps(player, trigger) then
                if not runState.rewardedLocations[rewardId] then
                    grant(runState, reward)
                    runState.rewardedLocations[rewardId] = true
                end

                local target = reward.toByDay
                    and reward.toByDay[runState.day] or reward.to
                if target then
                    registry:spawn({
                        switchRequest = {
                            to = target,
                            payload = { x = reward.enterX, y = reward.enterY },
                        },
                    })
                    return
                end
                break
            end
        end
    end
end

return LocationRewardSystem
