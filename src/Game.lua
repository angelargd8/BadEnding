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

local factories = {} -- scene name -> function(payload) -> Scene
local current = nil
local runState = nil
local sceneStack = {}

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
        runState = RunState.load()
    end
    performSwitch(name, nil)
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

function Game.keypressed(key)
    if key == "escape" then -- quitting is a Game concern, not a scene's
        love.event.quit()
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
