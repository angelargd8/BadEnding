local Game = require("src.Game")
local DebugOverlay = require("src.debug.DebugOverlay")
local attachDebugOverlay = require("src.debug.attach")

function love.load(args)
    Game.registerScene("opening", require("src.scenes.OpeningScene"))
    Game.registerScene("week", require("src.scenes.WeekScene"))
    Game.registerScene("packLab", require("src.scenes.PackLabScene"))
    Game.registerScene("collection", require("src.scenes.CollectionScene"))
    Game.registerScene("packOpening", require("src.scenes.PackOpeningScene"))

    Game.start("opening")

    attachDebugOverlay(Game)
    if args[1] == "--debug" then
        DebugOverlay.enterEditor()
    end
end

function love.update(dt)
    Game.update(dt)
end

function love.draw()
    Game.draw()
end

function love.keypressed(key)
    Game.keypressed(key)
end

function love.mousepressed(x, y, button, istouch, presses)
    Game.mousepressed(x, y, button, istouch, presses)
end

function love.quit()
    Game.quit()
end
