-- Updates Mizuki's relationship scores and derives the weekly and final outcomes.

local Relationship = {}
local FRIENDSHIP_LIMIT = 30
local OBSESSION_WIN_LIMIT = 15
local OBSESSION_LOSS_PER_HATE = 3
local OBSESSION_LOSS_PER_FRIENDLY_CARD = 5

local function count(value)
    return math.max(0, tonumber(value) or 0)
end

local function reduceObsession(relationship, points)
    relationship.obsession = math.max(0, count(relationship.obsession) - points)
end

function Relationship.addPoint(runState, key)
    local relationship = runState.relationship
    relationship[key] = count(relationship[key]) + 1
    if key == "hate" then
        reduceObsession(relationship, OBSESSION_LOSS_PER_HATE)
    end
end

function Relationship.applyCard(runState, responseType)
    if responseType == "hate" or responseType == "obsession" then
        Relationship.addPoint(runState, responseType)
        return responseType
    end
    -- Older cards without a response type also act as friendship cards.
    Relationship.addPoint(runState, "friendshipness")
    reduceObsession(runState.relationship, OBSESSION_LOSS_PER_FRIENDLY_CARD)
    return "friendship"
end

function Relationship.rates(runState)
    local relationship = runState.relationship or {}
    local obsession = count(relationship.obsession)
    local hate = count(relationship.hate)
    local friendship = count(relationship.friendshipness)
    local total = obsession + hate + friendship

    if total == 0 then
        return { obsession = 0, hate = 0, friendship = 0, total = 0 }
    end

    return {
        obsession = obsession / total * 100,
        hate = hate / total * 100,
        friendship = friendship / total * 100,
        total = total,
    }
end

function Relationship.level(rates)
    if rates.hate >= FRIENDSHIP_LIMIT then return "RECHAZO" end
    if rates.obsession >= 60 then return "OBSESION" end
    if rates.obsession >= OBSESSION_WIN_LIMIT then return "IDEALIZACION" end
    return "AMISTAD POSIBLE"
end

function Relationship.finalOutcome(runState)
    local rates = Relationship.rates(runState)
    if rates.hate >= FRIENDSHIP_LIMIT then return "hate" end
    if rates.obsession >= OBSESSION_WIN_LIMIT then return "obsession" end
    return "friends"
end

return Relationship
