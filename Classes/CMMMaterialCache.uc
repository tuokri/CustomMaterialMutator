class CMMMaterialCache extends Object;

struct MatCacheEntry
{
    // var int MaterialID; // TODO: Redundant? Just use array index instead?
    var string MaterialName;
    var MaterialInterface LoadedMaterial;
    // var class<MaterialInterface> MaterialClass; // TODO: can we actually use this for anything? Some weird conditional casts?
};

// All custom master materials that should be loaded on startup.
// TODO: Consider using a hash map for faster read access.
// TODO: We could also do an alphabetically sorted list and optimize the search based on that.
var array<MatCacheEntry> CachedMats;

function LoadMaterials()
{
    local MaterialInterface LoadedMat;
    local int Idx;
    local int Count;

    `cmmlog("loading custom materials...");

    for (Idx = 0; Idx < CachedMats.Length; ++Idx)
    {
        // LoadedMat = MaterialInterface(DynamicLoadObject(CachedMats[Idx].MaterialName, CachedMats[Idx].MaterialClass));
        LoadedMat = MaterialInterface(DynamicLoadObject(CachedMats[Idx].MaterialName, class'MaterialInterface'));
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

function MaterialInterface GetMaterialByID(int MaterialID)
{
    if (MaterialID < CachedMats.Length)
    {
        return CachedMats[MaterialID].LoadedMaterial;
    }
}

function MaterialInterface GetMaterialByName(string MaterialName)
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

// function class<MaterialInterface> GetMaterialClassByID()
// {

// }

// function class<MaterialInterface> GetMaterialClassByName()
// {

// }

DefaultProperties
{
    CachedMats(0)=(MaterialName="VNTE-MaterialContainer2.TestMat")
    CachedMats(1)=(MaterialName="VNTE-MaterialContainer2.BlinkingTestMat")
    CachedMats(2)=(MaterialName="VNTE-MaterialContainer2.TestMatWithParams")
    CachedMats(3)=(MaterialName="VNTE-MaterialContainer2.TestMIC")
}
