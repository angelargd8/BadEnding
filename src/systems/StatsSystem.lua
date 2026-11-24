-- Bumps the hidden stat an activity trains. Note how little it knows:
-- not what a vignette is, not what's on screen — it reads the same
-- `activityPicked` event the vignette does and touches only RunState.
--
-- Los valores exactos se mantienen ocultos. El radar muestra la proporción
-- entre habilidades; el inspector permite ver los números durante desarrollo.

local activities = require("src.data.activities")

local StatsSystem = { name = "stats" }

function StatsSystem.update(scene, dt)
    for _, pick in scene.registry:each("activityPicked") do
        local runState = scene.registry:resource("runState")
        local stat = activities[pick.option].stat
        if stat then
            runState.stats[stat] = runState.stats[stat] + 1
        end

        runState.practice[pick.option] = (runState.practice[pick.option] or 0) + 1
        runState.weekPractice[pick.option] =
            (runState.weekPractice[pick.option] or 0) + 1
    end
end

return StatsSystem
