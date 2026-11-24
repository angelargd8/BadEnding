-- Chooses where a mini-game returns after the player exits it.

local MiniGameFlow = {}

function MiniGameFlow.returnRequest(runState, fallbackScene, fallbackPayload)
    if runState and runState.day == 6 then
        runState.timeOfDay = "6 PM"
        return { to = "deckBuilder" }
    end
    return { to = fallbackScene, payload = fallbackPayload }
end

return MiniGameFlow
