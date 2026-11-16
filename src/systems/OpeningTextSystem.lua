-- Displays the opening narration one page at a time. Enter and Space move
-- to the next page; the last page requests the weekly activity scene.

local Screen = require("src.Screen")

local OpeningTextSystem = { name = "openingText" }

local PAGES = {
    "Hace un mes se me declaró Mizuki Sui, una chica encantadora de primero, acepté salir con ella, pero...",
    "No sé si me gusta y no debería estar dudando en estar con ella. Pero por alguna razón me incomoda cuando me dice lo asombroso que soy, porque siento que solo es un aspecto superficial, entre otras cosas que cree de mí.",
    "Idealizado, no soy así.",
    "No me conoce, ni lo más mínimo...",
    "Le habla a todo el mundo que está saliendo conmigo, pero no me siento cómodo, porque habla de cosas que ni yo sabía de mí. Y le pregunta a las personas sobre mí, en vez de preguntarme.",
    "La escucho, pero ella parece que a mí no...",
    "No me gustan los lugares a donde quiere ir, la acompaño para no sentirme mal, pero...",
    "No me divierto.",
    "Tengo que hacer que se desenamore de mí.",
    "Antes que la empiece a odiar.",
    "Que me conozca y se dé cuenta de que no somos compatibles.",
}

local font, hintFont

function OpeningTextSystem.setup(scene)
    font = love.graphics.newFont(18)
    hintFont = love.graphics.newFont(11)
    scene.registry:setResource("opening", { page = 1 })
end

function OpeningTextSystem.unload(scene)
    font, hintFont = nil, nil
end

function OpeningTextSystem.update(scene, dt)
    local registry = scene.registry
    local opening = registry:resource("opening")
    local advance = false

    for _, keyPressed in registry:each("keyPressed") do
        if keyPressed.key == "return" or keyPressed.key == "space" then
            advance = true
            break
        end
    end

    if not advance then
        for _, mousePressed in registry:each("mousePressed") do
            if mousePressed.button == 1 then
                advance = true
                break
            end
        end
    end

    if advance then
        opening.page = opening.page + 1
        if opening.page > #PAGES then
            registry:spawn({
                switchRequest = { to = "week" },
            })
        end
    end
end

function OpeningTextSystem.draw(scene)
    local page = scene.registry:resource("opening").page
    local text = PAGES[page]

    love.graphics.clear(0.055, 0.065, 0.105, 1)
    if not text then return end

    local width = Screen.w - 96
    local _, lines = font:getWrap(text, width)
    local height = #lines * font:getHeight()
    local x = (Screen.w - width) / 2
    local y = (Screen.h - height) / 2

    love.graphics.setColor(0.94, 0.89, 0.76, 1)
    love.graphics.setFont(font)
    love.graphics.printf(text, x, y, width, "center")
    love.graphics.setColor(1, 1, 1, 0.58)
    love.graphics.setFont(hintFont)
    love.graphics.printf("C: ver colección", 0, Screen.h - 24,
        Screen.w, "center")
    love.graphics.setColor(1, 1, 1, 1)
end

return OpeningTextSystem
