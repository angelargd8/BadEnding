-- Browses the cards earned during play. The shared runState is injected by
-- Game; this scene owns only its temporary cursor and page selection.

local Scene = require("src.ecs.Scene")

local CollectionInputSystem = require("src.systems.CollectionInputSystem")
local CollectionSelectionSystem = require("src.systems.CollectionSelectionSystem")
local CollectionChromeRenderSystem = require("src.systems.CollectionChromeRenderSystem")
local CollectionGridRenderSystem = require("src.systems.CollectionGridRenderSystem")
local CardDetailRenderSystem = require("src.systems.CardDetailRenderSystem")

return function(payload)
    local scene = Scene.new("collection")

    scene.registry:setResource("collectionView", {
        selected = 0,
        page = 1,
        columns = 5,
        pageSize = 10,
        mode = "browse",
    })

    scene:addSystem(CollectionInputSystem)
    scene:addSystem(CollectionSelectionSystem)
    scene:addSystem(CollectionChromeRenderSystem)
    scene:addSystem(CollectionGridRenderSystem)
    scene:addSystem(CardDetailRenderSystem)

    return scene
end
