-- Run from the repository with: lovec tests/playthroughs
-- Five six-week campaigns driven by player inputs. LÖVE owns all random draws.
local root = assert(love.filesystem.getSource():gsub("\\", "/"):match("^(.*)/tests/playthroughs/?$"))
package.path = root .. "/?.lua;" .. package.path

local Game = require("src.Game")
local Relationship = require("src.state.Relationship")
local deckRules = require("src.data.deck_builder_rules")
local dateRules = require("src.data.cafe_appointment_rules")
local SaveFile = require("src.state.SaveFile")
local IE = "emotional_intelligence"

-- Each schedule repeats for six weeks. A weekday excursion is taken on Monday
-- before choosing the activity. The Saturday destination follows the pack.
local trials = {
    { name = "Equilibrio", seed = 3096,
      days = { "study", "hobbies", IE, IE, IE }, weekday = "school",
      earlyClinic = true, saturday = "home", cards = "friendship",
      expected = { won = true, relationship = "friends", studyMet = true, happinessMet = true } },
    { name = "Respuestas hirientes", seed = 3097,
      days = { "study", "study", "study", "study", "hobbies" }, weekday = "school",
      weekdayGames = 2, saturday = "home", cards = "hate",
      expected = { won = false, relationship = "hate", studyMet = true, happinessMet = true } },
    { name = "Idealizacion", seed = 3098,
      days = { "hobbies", "hobbies", "hobbies", "hobbies", "charisma" },
      weekday = "school", saturday = "cafe", cards = "obsession",
      expected = { won = false, relationship = "obsession", studyMet = true, happinessMet = true } },
    { name = "Sin estudio", seed = 3099,
      days = { IE, IE, IE, IE, IE }, weekday = "clinic", saturday = "home", cards = "friendship",
      expected = { won = false, relationship = "friends", studyMet = false, happinessMet = true } },
    { name = "Sin pasatiempos", seed = 3100,
      days = { "study", IE, IE, IE, IE }, weekday = "clinic", saturday = "school", cards = "friendship",
      expected = { won = false, relationship = "friends", studyMet = true, happinessMet = false } },
}

local heldKey, saveBytes
local mouseX, mouseY = 0, 0
local endingText = {}
local function noop() end

-- Replace devices, drawing and save-file storage in this process only.
-- Game.update, scene transitions, collision detection and serialization run normally.
local function startEngine()
    love.keyboard = { isDown = function(key) return key == heldKey end }
    love.mouse = { getPosition = function() return mouseX, mouseY end }
    love.graphics = {
        newFont = function(size)
            return { getWidth = function(_, s) return #s * size end,
                getHeight = function() return size end }
        end,
        newImage = function() return { setFilter = noop } end,
        clear = noop, setColor = noop, rectangle = noop, setFont = noop,
        printf = function(s) endingText[#endingText + 1] = s end,
    }
    local read = love.filesystem.read
    love.filesystem.read = function(path, ...)
        if path == SaveFile.FILENAME then return saveBytes end
        return read(path, ...)
    end
    love.filesystem.write = function(path, bytes)
        assert(path == SaveFile.FILENAME, path)
        saveBytes = bytes
        return true
    end
    assert(loadfile(root .. "/main.lua"))()
    love.load({})
end

local function expectScene(name)
    local current = Game.current()
    assert(current.name == name, ("Expected %s, reached %s"):format(name, current.name))
    return current.registry
end

local function press(key)
    Game.keypressed(key)
    Game.update(0)
end

local function click(x, y)
    mouseX, mouseY = x, y
    Game.mousepressed(x, y, 1)
    Game.update(0)
end

-- Hold one direction until a waypoint or a normal scene transition is reached.
local function walk(axis, target)
    local start = Game.current()
    local _, pos = start.registry:each("position", "body")()
    local speed = start.registry:resource("map").speed
    while Game.current() == start and math.abs(target - pos[axis]) > .001 do
        local delta = target - pos[axis]
        if axis == "x" then heldKey = delta > 0 and "right" or "left"
        else heldKey = delta > 0 and "down" or "up" end
        local before = pos[axis]
        Game.update(math.min(1/30, math.abs(delta) / speed))
        heldKey = nil
        assert(Game.current() ~= start or math.abs(pos[axis] - before) > .0001,
            ("Blocked in %s at %.1f, %.1f"):format(start.name, pos.x, pos.y))
    end
end

local rooms = { school = "schoolInterior", clinic = "clinicInterior", home = "homeInterior" }
local games = { school = "game2048", clinic = "flappyBird", home = "snake" }
local training = { school = "study", clinic = IE, home = "hobbies" }

local function enterVenue(place)
    if place == "home" then
        expectScene("homeInterior")
        walk("x", 448)
        walk("y", 80)
    else
        if Game.current().name == "homeInterior" then walk("y", 328) end
        expectScene("map")
        walk("y", 145)
        if place == "school" then
            walk("x", 502)
            walk("y", 100)
            expectScene("schoolInterior")
            walk("x", 408)
        else
            walk("x", 576)
            expectScene("eastMap")
            walk("y", 145)
            walk("x", place == "clinic" and 144 or 416)
            walk("y", 95)
            if place == "clinic" then
                expectScene("clinicInterior")
                walk("y", 140)
            else
                expectScene("cafeInterior")
                walk("x", 408)
                walk("y", 108)
            end
        end
    end
    expectScene(games[place] or "deckBuilder")
end

local moves = { "left", "up", "right", "down" }
local function playMini(place)
    local reg = expectScene(games[place])
    local state = reg:resource("runState")
    local before = state.practice[training[place]]
    local board = reg:resource(games[place])
    if place == "clinic" then press("space") end
    for step = 1, 8000 do
        if board.progressGranted then break end
        if place == "school" then press(moves[(step - 1) % #moves + 1])
        else Game.update(1/30) end
    end
    assert((board.gameOver or board.won) and board.progressGranted, "Mini-game did not finish")
    assert(state.practice[training[place]] == before + 5, "Incorrect mini-game reward")
end

local function visit(place, repetitions, weekday)
    if weekday then press("m") end
    enterVenue(place)
    if place == "cafe" then return end
    for n = 1, repetitions do
        if n > 1 then press("r") end
        playMini(place)
    end
    press("b")
    if weekday then
        expectScene(rooms[place])
        press("m")
        expectScene("map")
        press("m")
        expectScene("week")
    else
        expectScene("deckBuilder")
    end
end

local function chooseActivity(activity)
    local reg = expectScene("week")
    local _, pos, menu = reg:each("position", "menu")()
    local before = reg:resource("runState").practice[activity]
    for i, option in ipairs(menu.options) do
        if option == activity then click(pos.x + (i - 1) * menu.spacing + 16, pos.y + 16) end
    end
    assert(reg:resource("runState").practice[activity] == before + 1)
    assert(reg:resource("dayloop").phase == "vignette")
    for _ = 1, 120 do
        Game.update(.05)
        if Game.current().name == "packOpening" or reg:resource("dayloop").phase == "choosing" then return end
    end
    error("Day did not advance")
end

local preferences = {
    friendship = { friendship = 1, hate = 2, obsession = 3 },
    hate = { hate = 1, friendship = 2, obsession = 3 },
    obsession = { obsession = 1, friendship = 2, hate = 3 },
}

local function playDate(state, strategy, played)
    expectScene("deckBuilder")
    local collection, order = state.collection, {}
    for i = 1, #collection do order[i] = i end
    local rank = preferences[strategy]
    table.sort(order, function(a, b)
        local ra, rb = rank[collection[a].responseType], rank[collection[b].responseType]
        if ra == rb then return a < b end
        return ra < rb
    end)
    local before, expected = #collection, {}
    for i = 1, deckRules.handSize do
        local index = order[i]
        expected[i] = collection[index].collectionId
        local slot = index - 1
        click(deckRules.cardX + slot % deckRules.columns * (deckRules.cardW + deckRules.gapX) + 10,
            deckRules.cardY + math.floor(slot / deckRules.columns) * (deckRules.cardH + deckRules.gapY) + 10)
    end
    press("return")
    local battle = expectScene("cafeAppointment"):resource("cafeAppointment")
    assert(#battle.hand == deckRules.handSize)
    for i, id in ipairs(expected) do assert(battle.hand[i].collectionId == id) end
    for turn = 1, dateRules.exchangeCount do
        assert(battle.phase == "mizuki" and battle.turn == turn)
        press("return")
        assert(battle.phase == "choose" and battle.selected == turn)
        local previousHate = state.relationship.hate
        local previousObsession = state.relationship.obsession
        press("return")
        assert(battle.phase == "result" and #battle.history == turn)
        local kind = battle.history[turn].responseType
        if kind == "hate" then
            assert(state.relationship.hate == previousHate + 1)
            assert(state.relationship.obsession == math.max(0, previousObsession - 3))
        end
        played[kind] = played[kind] + 1
        press("return")
    end
    assert(battle.dateResolved and #collection == before - dateRules.exchangeCount)
    press("return")
    expectScene("sundaySummary")
    assert(state.day == 7)
    return battle.dateWon
end

local function campaign(trial)
    love.math.setRandomSeed(trial.seed)
    saveBytes = nil
    expectScene("mainMenu")
    press("return")
    expectScene("opening")
    for _ = 1, 50 do
        if Game.current().name == "week" then break end
        press("return")
    end
    local state = expectScene("week"):resource("runState")
    assert(state.week == 1 and state.day == 1 and #state.collection == 0)
    local initial = Relationship.rates(state)
    assert(initial.obsession == 75 and initial.friendship == 25 and initial.hate == 0)
    local played = { friendship = 0, hate = 0, obsession = 0 }
    local positiveDates = 0
    for week = 1, 6 do
        assert(state.week == week)
        visit(trial.weekday, trial.weekdayGames or 1, true)
        if trial.earlyClinic and week == 1 then visit("clinic", 2, true) end
        local beforePack = #state.collection
        for day, activity in ipairs(trial.days) do
            assert(state.day == day)
            chooseActivity(activity)
        end
        expectScene("packOpening")
        assert(state.day == 6 and state.packWeek == week and #state.latestPack == 5)
        assert(#state.collection == beforePack + #state.latestPack)
        press("return")
        expectScene("homeInterior")
        visit(trial.saturday, 1, false)
        if playDate(state, trial.cards, played) then positiveDates = positiveDates + 1 end
        press("return")
    end
    local result = expectScene("ending"):resource("ending").result
    for key, expected in pairs(trial.expected) do
        assert(result[key] == expected, ("%s: expected %s=%s, got %s")
            :format(trial.name, key, tostring(expected), tostring(result[key])))
    end
    local saved = assert(SaveFile.load())
    assert(saved.scene == "ending" and saved.payload.result.won == result.won)
    assert(played.friendship + played.hate + played.obsession == 24 and #state.collection == 6)
    endingText = {}
    Game.draw()
    assert(endingText[1] == (result.won and "GANASTE" or "PERDISTE"))
    local rates = Relationship.rates(state)
    print(("%d %s | %s | enam %.2f | odio %.2f | estudio %.2f | felicidad %.2f | cartas A/Od/Ob %d/%d/%d | citas positivas %d/6")
        :format(trial.seed, trial.name, endingText[1], rates.obsession, rates.hate,
            result.studyPercent, result.happinessPercent, played.friendship, played.hate, played.obsession, positiveDates))
    for i = 2, #endingText - 1 do print("  " .. endingText[i]) end
    press("return")
    expectScene("mainMenu")
end

function love.run()
    return function()
        local ok, failure = xpcall(function()
            startEngine()
            for _, trial in ipairs(trials) do campaign(trial) end
        end, debug.traceback)
        if not ok then io.stderr:write(failure .. "\n") end
        return ok and 0 or 1
    end
end
