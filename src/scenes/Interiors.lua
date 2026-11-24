-- Factories for the house, school, cafe, and clinic interior maps.

local InteriorScene = require("src.scenes.InteriorScene")

return {
    home = InteriorScene.new({
        name = "homeInterior",
        floor = "wood",
        returnTo = "map",
        returnX = 44,
        exitTimeOfDay = "PM",
        exitTimeDay = 6,
        furniture = {
            { path = "assets/interior_props.png", w = 128, h = 128,
                frame = 1, row = 1, x = 64, y = 48 }, -- bed
            { path = "assets/interior_props.png", w = 128, h = 128,
                frame = 2, row = 1, x = 432, y = 48 }, -- sofa
            { path = "assets/pink_round_rug.png", w = 96, h = 96,
                frame = 1, row = 1, x = 272, y = 172 }, -- round pink rug
        },
        triggers = {
            { x = 456, y = 104, w = 48, h = 40, to = "snake" },
        },
        rewardTriggers = {
            { x = 456, y = 104, w = 48, h = 40,
                key = "home", activity = "hobbies" },
        },
    }),

    school = InteriorScene.new({
        name = "schoolInterior",
        floor = "schoolFloor",
        returnTo = "map",
        returnX = 514,
        furniture = {
            -- Three columns by three rows; keep the south aisle clear for
            -- the entrance. The solid rectangles stop the player walking
            -- through the desks while leaving their seats approachable.
            { frame = 3, row = 4, x = 64, y = 48, scale = 2,
                solid = { x = 4, y = 18, w = 24, h = 14 } },
            { frame = 3, row = 4, x = 288, y = 48, scale = 2,
                solid = { x = 4, y = 18, w = 24, h = 14 } },
            { frame = 3, row = 4, x = 512, y = 48, scale = 2,
                solid = { x = 4, y = 18, w = 24, h = 14 } },
            { frame = 3, row = 4, x = 64, y = 136, scale = 2,
                solid = { x = 4, y = 18, w = 24, h = 14 } },
            { frame = 3, row = 4, x = 288, y = 136, scale = 2,
                solid = { x = 4, y = 18, w = 24, h = 14 } },
            { frame = 3, row = 4, x = 512, y = 136, scale = 2,
                solid = { x = 4, y = 18, w = 24, h = 14 } },
            { frame = 3, row = 4, x = 64, y = 224, scale = 2,
                solid = { x = 4, y = 18, w = 24, h = 14 } },
            { frame = 3, row = 4, x = 288, y = 224, scale = 2,
                solid = { x = 4, y = 18, w = 24, h = 14 } },
            { frame = 3, row = 4, x = 512, y = 224, scale = 2,
                solid = { x = 4, y = 18, w = 24, h = 14 } },
            -- A book stack lies in the clear aisle to the right of the
            -- last desk row; touching it starts the 2048 mini-game.
            { frame = 4, row = 4, x = 416, y = 304, scale = 2 },
        },
        triggers = {
            { x = 416, y = 304, w = 64, h = 64, to = "game2048" },
        },
        rewardTriggers = {
            { x = 416, y = 304, w = 64, h = 64,
                key = "school", activity = "study" },
        },
    }),

    cafe = InteriorScene.new({
        name = "cafeInterior",
        floor = "cafeteriaFloor",
        returnTo = "eastMap",
        returnX = 416,
        furniture = {
            { frame = 4, row = 3, x = 160, y = 104, scale = 2 },
            { frame = 3, row = 3, x = 88, y = 104, scale = 2 },
            { frame = 2, row = 3, x = 232, y = 104, scale = 2 },
            { frame = 4, row = 3, x = 416, y = 104, scale = 2 },
            { frame = 3, row = 3, x = 344, y = 104, scale = 2 },
            { frame = 2, row = 3, x = 488, y = 104, scale = 2 },
            { path = "assets/mizuki_sitting.png", w = 32, h = 32,
                frame = 1, row = 1, x = 488, y = 96, scale = 2 }, -- seated on the upper-right chair
            { frame = 4, row = 3, x = 160, y = 224, scale = 2 },
            { frame = 3, row = 3, x = 88, y = 224, scale = 2 },
            { frame = 2, row = 3, x = 232, y = 224, scale = 2 },
            { frame = 4, row = 3, x = 416, y = 224, scale = 2 },
            { frame = 3, row = 3, x = 344, y = 224, scale = 2 },
            { frame = 2, row = 3, x = 488, y = 224, scale = 2 },
        },
        rewardTriggers = {
            { x = 344, y = 88, w = 208, h = 80,
                key = "cafe", activity = "charisma", relationship = "obsession",
                toByDay = { [6] = "deckBuilder" } },
        },
    }),

    clinic = InteriorScene.new({
        name = "clinicInterior",
        floor = "schoolFloor",
        returnTo = "eastMap",
        returnX = 144,
        furniture = {
            { path = "assets/interior_props.png", w = 128, h = 128,
                frame = 1, row = 2, x = 64, y = 88 }, -- waiting sofa
            { path = "assets/interior_props.png", w = 128, h = 128,
                frame = 3, row = 2, x = 448, y = 88 }, -- armchair
            { path = "assets/interior_props.png", w = 128, h = 128,
                frame = 2, row = 2, x = 24, y = 244, scale = 0.9 }, -- plant
            { path = "assets/interior_props.png", w = 128, h = 128,
                frame = 2, row = 2, x = 536, y = 244, scale = 0.9 }, -- plant
            { path = "assets/interior_props.png", w = 128, h = 128,
                frame = 4, row = 2, x = 256, y = 112, scale = 0.85 }, -- side table
        },
        triggers = {
            { x = 292, y = 164, w = 40, h = 40, to = "flappyBird" },
        },
        rewardTriggers = {
            { x = 292, y = 164, w = 40, h = 40,
                key = "clinic", activity = "emotional_intelligence" },
        },
    }),
}
