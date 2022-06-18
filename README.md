# Custom Material Mutator

Proof-of-Concept RS2 mutator that shows how to load custom master materials from a separate dedicated level file that contains the materials.

https://steamcommunity.com/sharedfiles/filedetails/?id=2822726525

Custom master materials do not work out of the box because the game does not know how to load shader caches from mod packages. The game does however know how to load them from level packages. The custom master materials are places in a separate level that only contains the custom master materials (in order to keep file size and load times small). The level should also contain some dummy actors (2D plane meshes or something similar) that reference the materials to keep the garbage collector from removing the materials when the level is saved.
