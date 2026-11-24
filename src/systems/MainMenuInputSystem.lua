-- Reads keyboard and pointer input for the title screen.

local Mouse = require("src.Mouse")

local MainMenuInputSystem = { name = "mainMenuInput" }
local BUTTON_X, BUTTON_W, BUTTON_H = 196, 248, 34

local function moveSelection(menu, direction)
    local nextIndex = (menu.selected - 1 + direction) % #menu.options + 1
    if nextIndex == 2 and not menu.canLoad then
        nextIndex = direction > 0 and 3 or 1
    end
    menu.selected = nextIndex
end

local function activate(scene, menu)
    local option = menu.options[menu.selected]
    if option.action == "load" and not menu.canLoad then
        return
    end
    scene.registry:spawn({
        mainMenuActionRequest = { action = option.action },
    })
end

function MainMenuInputSystem.update(scene)
    local registry = scene.registry
    local menu = registry:resource("mainMenu")

    local mx, my, inside = Mouse.position()
    if inside then
        for i, option in ipairs(menu.options) do
            if mx >= BUTTON_X and mx <= BUTTON_X + BUTTON_W
                    and my >= option.y and my <= option.y + BUTTON_H then
                if i ~= 2 or menu.canLoad then menu.selected = i end
            end
        end
    end

    for _, key in registry:each("keyPressed") do
        if key.key == "up" or key.key == "w" then
            moveSelection(menu, -1)
        elseif key.key == "down" or key.key == "s" then
            moveSelection(menu, 1)
        elseif key.key == "return" or key.key == "space" then
            activate(scene, menu)
        end
    end

    for _, mouse in registry:each("mousePressed") do
        if mouse.button == 1 and inside then
            for i, option in ipairs(menu.options) do
                if mx >= BUTTON_X and mx <= BUTTON_X + BUTTON_W
                        and my >= option.y and my <= option.y + BUTTON_H then
                    menu.selected = i
                    activate(scene, menu)
                    break
                end
            end
        end
    end
end

return MainMenuInputSystem
