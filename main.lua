local Game = require("src.Game")
local Audio = require("src.Audio")
local Interiors = require("src.scenes.Interiors")
local DebugOverlay = require("src.debug.DebugOverlay")
local attachDebugOverlay = require("src.debug.attach")
local WORLD_SCENES = {
    map = true,
    eastMap = true,
    homeInterior = true,
    schoolInterior = true,
    cafeInterior = true,
    clinicInterior = true,
}

function love.load(args)
    Audio.start()

    Game.registerScene("mainMenu", require("src.scenes.MainMenuScene"))
    Game.registerScene("week", require("src.scenes.WeekScene"))
    Game.registerScene("opening", require("src.scenes.OpeningScene"))
    Game.registerScene("packOpening", require("src.scenes.PackOpeningScene"))
    Game.registerScene("packLab", require("src.scenes.PackLabScene"))
    Game.registerScene("collection", require("src.scenes.CollectionScene"))
    Game.registerScene("animLab", require("src.scenes.AnimationLabScene"))
    Game.registerScene("tileLab", require("src.scenes.TileLabScene"))
    Game.registerScene("map", require("src.scenes.MapScene"))
    Game.registerScene("eastMap", require("src.scenes.EastMapScene"))
    Game.registerScene("cafeAppointment", require("src.scenes.CafeAppointmentScene"))
    Game.registerScene("deckBuilder", require("src.scenes.DeckBuilderScene"))
    Game.registerScene("sundaySummary", require("src.scenes.SundaySummaryScene"))
    Game.registerScene("ending", require("src.scenes.EndingScene"))
    Game.registerScene("homeInterior", Interiors.home)
    Game.registerScene("schoolInterior", Interiors.school)
    Game.registerScene("cafeInterior", Interiors.cafe)
    Game.registerScene("clinicInterior", Interiors.clinic)
    Game.registerScene("snake", require("src.scenes.SnakeScene"))
    Game.registerScene("flappyBird", require("src.scenes.FlappyBirdScene"))
    Game.registerScene("game2048", require("src.scenes.Game2048Scene"))

    local known, startScene = {}, "mainMenu"
    for _, name in ipairs(Game.sceneNames()) do
        known[name] = true
    end
    if known[args[1]] then
        startScene = args[1]
    end
    Game.start(startScene)

    attachDebugOverlay(Game)
    for _, arg in ipairs(args) do
        if arg == "--debug" then
            DebugOverlay.enterEditor()
        end
    end
end

function love.update(dt)
    Game.update(dt)
end

function love.draw()
    Game.draw()
end

function love.keypressed(key)
    local sceneName = Game.current().name
    local isArrow = key == "up" or key == "down"
        or key == "left" or key == "right"
    local isConfirm = key == "return" or key == "space"
    if sceneName ~= "opening"
            and not (WORLD_SCENES[sceneName] and isArrow)
            and (isArrow or isConfirm) then
        Audio.playClick()
    end
    Game.keypressed(key)
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 and Game.current().name ~= "opening" then
        Audio.playClick()
    end
    Game.mousepressed(x, y, button, istouch, presses)
end

function love.quit()
    Game.quit()
end
