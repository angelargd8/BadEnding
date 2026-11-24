-- Shared audio that stays alive while scenes change.

local Audio = {}
local music
local clickSound

local function makeClickSound()
    local sampleRate = 44100
    local duration = 0.075
    local samples = math.floor(sampleRate * duration)
    local data = love.sound.newSoundData(samples, sampleRate, 16, 1)

    for index = 0, samples - 1 do
        local time = index / sampleRate
        local envelope = (1 - time / duration) ^ 3
        local tone = math.sin(2 * math.pi * 920 * time)
        data:setSample(index, tone * envelope * 0.35)
    end

    return love.audio.newSource(data, "static")
end

function Audio.start()
    if not music then
        music = love.audio.newSource("assets/YuYu Hakusho - Romantic!.mp3", "stream")
        music:setLooping(true)
        music:setVolume(0.35)
        clickSound = makeClickSound()
        clickSound:setVolume(0.3)
    end

    if not music:isPlaying() then
        music:play()
    end
end

function Audio.playClick()
    if clickSound then
        clickSound:stop()
        clickSound:play()
    end
end

return Audio
