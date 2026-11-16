-- Se eligen respuestas de la colección sin repetirlas en la misma mano.
-- La colección original no se modifica.

local HandGenerator = {}

local function defaultRandom(...)
    return love.math.random(...)
end

function HandGenerator.draw(collection, count, random)
    count = count or 5
    random = random or defaultRandom
    assert(#collection >= count, "not enough cards to draw a hand")

    -- Partial Fisher-Yates: after each swap, slot i is a final draw. We stop
    -- after `count` positions instead of shuffling the rest of the collection.
    local candidates = {}
    for i, card in ipairs(collection) do candidates[i] = card end

    local hand = {}
    for i = 1, count do
        local picked = random(i, #candidates)
        candidates[i], candidates[picked] = candidates[picked], candidates[i]
        hand[i] = candidates[i]
    end
    return hand
end

return HandGenerator
