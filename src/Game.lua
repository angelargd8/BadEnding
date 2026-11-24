-- The Game: owns the scenes and switches between them. There is exactly
-- one Game, so it's a plain module (require caches it), not a class.
--
-- Nobody calls a switch function directly. To change scenes, ANY system
-- spawns an event entity in its own registry:
--
--   registry:spawn({ switchRequest = { to = "gameover", payload = {...} } })
--
-- and the Game honors it AFTER the frame's update — never in the middle
-- of one, when the current scene's systems are still iterating the very
-- registry that a switch would destroy. Deferred transitions like this
-- are how real engines avoid that whole class of crashes.

local Game = {}
local RunState = require("src.state.RunState")
local SaveFile = require("src.state.SaveFile")

local factories = {} -- scene name -> function(payload) -> Scene
local current = nil
local runState = nil
local sceneStack = {}

local MAP_EXIT_SCENES = {
    map = true,
    eastMap = true,
    homeInterior = true,
    schoolInterior = true,
    cafeInterior = true,
    clinicInterior = true,
    snake = true,
    flappyBird = true,
    game2048 = true,
    cafeAppointment = true,
    deckBuilder = true,
}

local SAVEABLE_SCENES = {
    opening = true,
    week = true,
    packOpening = true,
    homeInterior = true,
    schoolInterior = true,
    map = true,
    eastMap = true,
    cafeInterior = true,
    clinicInterior = true,
    cafeAppointment = true,
    deckBuilder = true,
    sundaySummary = true,
    ending = true,
    snake = true,
    flappyBird = true,
    game2048 = true,
}

-- Scenes register a factory, not an instance: every entry builds the
-- scene fresh, so no stale state can survive a visit.
function Game.registerScene(name, factory)
    factories[name] = factory
end

local function performSwitch(name, payload)
    assert(factories[name], "unknown scene: " .. tostring(name))
    -- A normal transition replaces the active flow, so discard any modal
    -- collection scenes suspended by the shortcut.
    for i = #sceneStack, 1, -1 do
        sceneStack[i]:unload()
        sceneStack[i] = nil
    end
    if current then
        current:unload()
    end
    current = factories[name](payload)
    current.registry:setResource("runState", runState)
    current:setup()
end

local function pushScene(name, payload)
    assert(factories[name], "unknown scene: " .. tostring(name))
    sceneStack[#sceneStack + 1] = current
    current = factories[name](payload)
    current.registry:setResource("runState", runState)
    current:setup()
end

local function popScene()
    if #sceneStack == 0 then return false end
    current:unload()
    current = table.remove(sceneStack)
    return true
end

function Game.start(name)
    -- Load or create the plain-data state once. Every scene receives this
    -- same table, so switching scenes cannot reset progress or collection.
    if not runState then
        runState = name == "mainMenu" and RunState.new() or RunState.load()
    end
    performSwitch(name, nil)
end

function Game.startNewGame()
    runState = RunState.new()
    SaveFile.save({
        runState = runState,
        scene = "opening",
        payload = { page = 1 },
    })
    performSwitch("opening")
end

local function inferSavedScene(saved, state)
    if type(saved.scene) == "string" and SAVEABLE_SCENES[saved.scene]
            and factories[saved.scene] then
        return saved.scene
    end
    if state.day == 7 then return "sundaySummary" end
    if state.day == 6 then
        return state.packWeek == state.week and "homeInterior" or "packOpening"
    end
    return "week"
end

function Game.loadSavedGame()
    local saved = SaveFile.load()
    if type(saved) ~= "table" or type(saved.runState) ~= "table" then
        return false
    end

    runState = RunState.restore(saved.runState)
    performSwitch(inferSavedScene(saved, runState), saved.payload)
    return true
end

local function sceneSavePayload(scene)
    local registry = scene.registry
    local payload = {}
    for _, position in registry:each("position", "body") do
        payload.x, payload.y = position.x, position.y
        break
    end

    local opening = registry:resource("opening")
    if opening then payload.page = opening.page end

    local packOpening = registry:resource("packOpening")
    if packOpening then payload.selectedCard = packOpening.selected end

    local snake = registry:resource("snake")
    if snake then payload.snake = snake end

    local flappyBird = registry:resource("flappyBird")
    if flappyBird then payload.flappyBird = flappyBird end

    local game2048 = registry:resource("game2048")
    if game2048 then payload.game2048 = game2048 end

    local cafeAppointment = registry:resource("cafeAppointment")
    if cafeAppointment then payload.cafeAppointment = cafeAppointment end

    local deckBuilder = registry:resource("deckBuilder")
    if deckBuilder then payload.deckBuilder = deckBuilder end

    local ending = registry:resource("ending")
    if ending then payload.result = ending.result end

    local dayloop = registry:resource("dayloop")
    if dayloop then
        payload.dayloop = {
            phase = dayloop.phase,
            timer = dayloop.timer,
            flipped = dayloop.flipped,
        }
        local _, menu = registry:first("menu")
        if menu then payload.menuCursor = menu.cursor end
        local _, textbox = registry:first("textbox")
        if textbox then
            payload.textbox = {
                text = textbox.text,
                visibleChars = textbox.visibleChars,
            }
        end
    end
    return payload
end

function Game.save()
    if not current then return false, "No hay una partida activa" end

    local scene = current
    -- The collection browser is modal. Save the scene underneath it so
    -- loading returns to the game instead of reopening the browser.
    if scene.name == "collection" then
        scene = sceneStack[#sceneStack]
    end
    if not scene or not SAVEABLE_SCENES[scene.name] then
        return false, "Esta escena no se puede guardar"
    end

    local ok, message = SaveFile.save({
        runState = runState,
        scene = scene.name,
        payload = sceneSavePayload(scene),
    })
    if ok then return true end
    return false, message or "No se pudo escribir el archivo de guardado"
end

function Game.update(dt)
    current:update(dt)

    -- events are broadcasts: systems READ them, nobody destroys them.
    -- ANY entity spawned with the `event` marker component lives for
    -- exactly one update — the Game sweeps them all here, once the
    -- frame is over. (Bevy's Events<T> work the same way: writers
    -- push, readers poll, the runtime clears.)
    for _, entity in ipairs(current.registry:query("event")) do
        current.registry:destroy(entity)
    end

    local menuActionEntity, menuAction = current.registry:first("mainMenuActionRequest")
    if menuAction then
        current.registry:destroy(menuActionEntity)
        if menuAction.action == "start" then
            Game.startNewGame()
        elseif menuAction.action == "load" then
            if not Game.loadSavedGame() then
                local menu = current.registry:resource("mainMenu")
                if menu then menu.message = "No hay una partida guardada." end
            end
        elseif menuAction.action == "quit" then
            love.event.quit()
        end
        return
    end

    -- Modal scene requests are handled after the update, just like a normal
    -- scene switch. The suspended scene remains alive and resumes unchanged.
    local popEntity = current.registry:first("popSceneRequest")
    if popEntity then
        current.registry:destroy(popEntity)
        popScene()
        return
    end

    local pushEntity, pushRequest = current.registry:first("pushSceneRequest")
    if pushRequest then
        current.registry:destroy(pushEntity)
        pushScene(pushRequest.to, pushRequest.payload)
        return
    end

    -- the frame is over; now it's safe to honor a switch request
    local _, request = current.registry:first("switchRequest")
    if request then
        performSwitch(request.to, request.payload)
    end
end

function Game.draw()
    current:draw()
end

local function weekResumePayload(scene)
    local registry = scene.registry
    local day = registry:resource("dayloop") or {}
    local _, menu = registry:first("menu")
    local _, textbox = registry:first("textbox")
    return {
        dayloop = {
            phase = day.phase or "choosing",
            timer = day.timer or 0,
            flipped = day.flipped or false,
        },
        menuCursor = menu and menu.cursor or 1,
        textbox = textbox and {
            text = textbox.text,
            visibleChars = textbox.visibleChars,
        } or nil,
    }
end

function Game.keypressed(key)
    if key == "escape" then -- quitting is a Game concern, not a scene's
        love.event.quit()
        return
    end
    if key == "m" then
        if current and current.name == "week" then
            local runState = current.registry:resource("runState")
            if runState then
                runState.weekResume = weekResumePayload(current)
            end
            current.registry:spawn({
                switchRequest = { to = "map" },
            })
            return
        elseif current and current.name == "map" then
            local runState = current.registry:resource("runState")
            local resume = runState and runState.weekResume
            if resume then
                runState.weekResume = nil
                current.registry:spawn({
                    switchRequest = { to = "week", payload = resume },
                })
            end
            return
        end

        local source = current
        if source and source.name == "collection" then
            source = sceneStack[#sceneStack]
        end
        if source and MAP_EXIT_SCENES[source.name] and source.name ~= "map" then
            current.registry:spawn({
                switchRequest = {
                    to = "map",
                    payload = { x = 288, y = 260 },
                },
            })
        end
        return
    end
    if key == "c" and current.name ~= "collection" then
        if not current.registry:first("pushSceneRequest") then
            current.registry:spawn({
                pushSceneRequest = { to = "collection" },
            })
        end
        return
    end
    -- everything else enters the world as DATA: a `keyPressed` event
    -- entity. LÖVE delivers key events BEFORE love.update, so every
    -- system sees it during this frame's update; Game.update sweeps it
    -- afterwards.
    current.registry:spawn({ event = true, keyPressed = { key = key } })
end

function Game.mousepressed(x, y, button, istouch, presses)
    current.registry:spawn({
        event = true,
        mousePressed = {
            x = x,
            y = y,
            button = button,
            istouch = istouch,
            presses = presses,
        },
    })
end

function Game.quit()
    if current then
        current:unload()
    end
    for i = #sceneStack, 1, -1 do
        sceneStack[i]:unload()
        sceneStack[i] = nil
    end
end

-- Handy for tests and (soon) debug tooling.
function Game.current()
    return current
end

-- Every registered scene name, sorted. Game code never needs this — it
-- always knows where it's going. It exists for TOOLS, same story as
-- Registry:entities(): the debug scene switcher asks "where could we
-- go?" without hardcoding a scene list.
function Game.sceneNames()
    local names = {}
    for name in pairs(factories) do
        names[#names + 1] = name
    end
    table.sort(names)
    return names
end

return Game
