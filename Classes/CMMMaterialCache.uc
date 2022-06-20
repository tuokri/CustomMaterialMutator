class CMMMaterialCache extends Object;

struct MatCacheEntry
{
    // var int MaterialID; // TODO: Redundant? Just use array index instead?
    var string MaterialName;
    var Material LoadedMaterial;
};

// All custom master materials that should be loaded on startup.
// TODO: Consider using a hash map for faster read access.
// TODO: We could also do an alphabetically sorted list and optimize the search based on that.
var array<MatCacheEntry> CachedMats;

function LoadMaterials()
{
    local Material LoadedMat;
    local int Idx;
    local int Count;

    `cmmlog("loading custom materials...");

    for (Idx = 0; Idx < CachedMats.Length; ++Idx)
    {
        LoadedMat = Material(DynamicLoadObject(CachedMats[Idx].MaterialName, class'Material'));
        if (LoadedMat == None)
        {
            `cmmlog("** !ERROR! ** cannot load material: " $ CachedMats[Idx].MaterialName);
            continue;
        }

        CachedMats[Idx].LoadedMaterial = LoadedMat;
        // CachedMats[Idx].MaterialID = Idx;
        Count++;
        `cmmlog("loaded " $ LoadedMat @ CachedMats[Idx].MaterialName);
    }

    `cmmlog("loaded " $ Count $ " custom materials");
}

function int GetMaterialID(string MaterialName)
{
    local int Idx;

    for (Idx = 0; Idx < CachedMats.Length; ++Idx)
    {
        if (Locs(CachedMats[Idx].MaterialName) == Locs(MaterialName))
        {
            return Idx;
        }
    }

    return -1;
}

function string GetMaterialName(int MaterialID)
{
    if (MaterialID < CachedMats.Length)
    {
        return CachedMats[MaterialID].MaterialName;
    }
    return "";
}

function Material GetMaterialByID(int MaterialID)
{
    if (MaterialID < CachedMats.Length)
    {
        return CachedMats[MaterialID].LoadedMaterial;
    }
}

function Material GetMaterialByName(string MaterialName)
{
    local MatCacheEntry Entry;

    ForEach CachedMats(Entry)
    {
        if (Locs(Entry.MaterialName) == Locs(MaterialName))
        {
            return Entry.LoadedMaterial;
        }
    }
}

DefaultProperties
{
    CachedMats(0)=(MaterialName="VNTE-MaterialContainer2.TestMat")
    CachedMats(1)=(MaterialName="VNTE-MaterialContainer2.BlinkingTestMat")
}
