-- Owns the 2048 board rules: tile spawning, merges, score, and end states.

local Game2048System = { name = "game2048" }
local MiniGameProgress = require("src.state.MiniGameProgress")

local SIZE = 4
local TARGET = 2048

local function newGame()
    local grid = {}
    for row = 1, SIZE do
        grid[row] = { 0, 0, 0, 0 }
    end
    return {
        grid = grid,
        score = 0,
        gameOver = false,
        won = false,
        progressGranted = false,
        waitingAfterWin = false,
    }
end

local function spawnTile(game)
    local empty = {}
    for row = 1, SIZE do
        for col = 1, SIZE do
            if game.grid[row][col] == 0 then
                empty[#empty + 1] = { row = row, col = col }
            end
        end
    end
    if #empty == 0 then return end

    local cell = empty[love.math.random(#empty)]
    game.grid[cell.row][cell.col] = love.math.random(10) == 1 and 4 or 2
end

local function lineCells(direction, line)
    local cells = {}
    for offset = 1, SIZE do
        local index = (direction == "left" or direction == "up")
            and offset or SIZE - offset + 1

        if direction == "left" or direction == "right" then
            cells[offset] = { row = line, col = index }
        else
            cells[offset] = { row = index, col = line }
        end
    end
    return cells
end

local function moveLine(game, cells)
    local values = {}
    for _, cell in ipairs(cells) do
        local value = game.grid[cell.row][cell.col]
        if value ~= 0 then values[#values + 1] = value end
    end

    local merged = {}
    local i = 1
    while i <= #values do
        if values[i] == values[i + 1] then
            local value = values[i] * 2
            merged[#merged + 1] = value
            game.score = game.score + value
            if value >= TARGET and not game.won then
                game.won = true
                game.waitingAfterWin = true
            end
            i = i + 2
        else
            merged[#merged + 1] = values[i]
            i = i + 1
        end
    end

    local changed = false
    for index, cell in ipairs(cells) do
        local value = merged[index] or 0
        if game.grid[cell.row][cell.col] ~= value then changed = true end
        game.grid[cell.row][cell.col] = value
    end
    return changed
end

local function canMove(game)
    for row = 1, SIZE do
        for col = 1, SIZE do
            local value = game.grid[row][col]
            if value == 0 then return true end
            if col < SIZE and value == game.grid[row][col + 1] then return true end
            if row < SIZE and value == game.grid[row + 1][col] then return true end
        end
    end
    return false
end

local function applyMove(game, direction)
    local changed = false
    for line = 1, SIZE do
        if moveLine(game, lineCells(direction, line)) then changed = true end
    end
    if changed then
        spawnTile(game)
        if not game.waitingAfterWin and not canMove(game) then
            game.gameOver = true
        end
    end
end

function Game2048System.setup(scene)
    local registry = scene.registry
    if not registry:resource("game2048") then
        local game = newGame()
        spawnTile(game)
        spawnTile(game)
        registry:setResource("game2048", game)
    end
    local game = registry:resource("game2048")
    if game.won or game.gameOver then
        MiniGameProgress.grant(registry:resource("runState"), game, "study")
    end
end

function Game2048System.update(scene)
    local game = scene.registry:resource("game2048")
    if game.restartRequested then
        game = newGame()
        spawnTile(game)
        spawnTile(game)
        scene.registry:setResource("game2048", game)
        return
    end

    local direction = game.moveRequested
    game.moveRequested = nil
    if direction and not game.gameOver and not game.waitingAfterWin then
        applyMove(game, direction)
    end
    if game.won or game.gameOver then
        MiniGameProgress.grant(scene.registry:resource("runState"), game,
            "study")
    end
end

return Game2048System
