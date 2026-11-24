-- An intentionally empty Saturday-evening date beat at the cafe.

local Scene = require("src.ecs.Scene")
local CafeAppointmentInputSystem = require("src.systems.CafeAppointmentInputSystem")
local CafeAppointmentRenderSystem = require("src.systems.CafeAppointmentRenderSystem")

return function(payload)
    payload = payload or {}
    local scene = Scene.new("cafeAppointment")
    if payload.cafeAppointment then
        scene.registry:setResource("cafeAppointment", payload.cafeAppointment)
    end
    scene:addSystem(CafeAppointmentInputSystem)
    scene:addSystem(CafeAppointmentRenderSystem)
    return scene
end
