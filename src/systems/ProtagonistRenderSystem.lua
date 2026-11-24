-- Draws the protagonist portrait in the open space of the weekly scene.

local ImageManager = require("src.graphics.ImageManager")

local ProtagonistRenderSystem = { name = "protagonistRender" }
local protagonistImage, blinkImage
local blinkTimer = 0
local textBlinkTriggered = false

local SCALE = 0.19
local X, Y = 116, 95
local BLINK_DURATION = 0.16

function ProtagonistRenderSystem.setup(scene)
    protagonistImage = ImageManager.load("assets/protagonist.png")
    blinkImage = ImageManager.load("assets/protagonist_blink.png")
    protagonistImage:setFilter("nearest", "nearest")
    blinkImage:setFilter("nearest", "nearest")

    blinkTimer = 0
    textBlinkTriggered = false
end

function ProtagonistRenderSystem.update(scene, dt)
    local registry = scene.registry
    if blinkTimer > 0 then
        blinkTimer = math.max(0, blinkTimer - dt)
    end

    -- Blink once as the activity is chosen and once when its vignette
    -- finishes typing, before the day transition begins.
    if registry:first("activityPicked") then
        blinkTimer = BLINK_DURATION
        textBlinkTriggered = false
    end

    local dayloop = registry:resource("dayloop")
    local _, textbox = registry:first("textbox")
    if dayloop and dayloop.phase == "vignette" and textbox
            and not textBlinkTriggered
            and textbox.visibleChars >= #textbox.text then
        blinkTimer = BLINK_DURATION
        textBlinkTriggered = true
    end
end

function ProtagonistRenderSystem.unload(scene)
    protagonistImage, blinkImage = nil, nil
end

function ProtagonistRenderSystem.draw(scene)
    love.graphics.setColor(1, 1, 1, 1)
    local image = blinkTimer > 0 and blinkImage or protagonistImage
    love.graphics.draw(image, X, Y, 0, SCALE, SCALE)
end

return ProtagonistRenderSystem
