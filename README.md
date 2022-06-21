# Custom Material Mutator

Proof of concept RS2 mutator with fully working replication that shows how to dynamically load custom master materials from a separate dedicated level file that contains the materials.

https://steamcommunity.com/sharedfiles/filedetails/?id=2823262858

Custom master materials do not work out of the box because the game does not know how to load shader caches from (cooked) mod packages. The game does however know how to load them from level packages. The custom master materials are placed in a separate level that only contains the custom master materials (in order to keep file size and load times small). The level should also contain some dummy actors (2D plane meshes or something similar) that reference the materials to keep the garbage collector from removing the materials when the level is saved. The level (and its shader cache) is then loaded with the `PrepareMapChange` function and the individual materials are loaded with `DynamicLoadObject`.
