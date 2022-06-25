class CMMCustomMaterialContainer extends ActorComponent
    dependson(CMMMaterialReplicationInfo);

struct MeshComponentMapping
{
    var int TargetCompID;
    var MeshComponent TargetComp;
};

struct MaterialMapping
{
    // Used to resolve target MeshComponent from MeshComponentMapping.TargetCompID.
    var int TargetCompID;
    // Material slot in the target MeshComponent.
    var byte MaterialIndex;
    // Full name of the material.
    var string MaterialName;
    // References index in CMMMaterialCache::CachedMats array.
    var int MaterialID;
};

var MaterialMapping MaterialMappings[`MAX_MATERIAL_MAPPINGS];
var array<MeshComponentMapping> MeshComponentMappings;

function MeshComponent GetTargetMeshComponent(int MeshCompID)
{
    local MeshComponentMapping MCMEntry;

    ForEach MeshComponentMappings(MCMEntry)
    {
        if (MCMEntry.TargetCompID == MeshCompID)
        {
            return MCMEntry.TargetComp;
        }
    }

    return None;
}

function int GetTargetMeshComponentID(MeshComponent MeshComp)
{
    local MeshComponentMapping MCMEntry;

    ForEach MeshComponentMappings(MCMEntry)
    {
        if (MCMEntry.TargetComp == MeshComp)
        {
            return MCMEntry.TargetCompID;
        }
    }

    return -1;
}

simulated function ApplyMaterials(optional int NumMappingsToApply = `MAX_MATERIAL_MAPPINGS,
    optional bool bReplicate = False, optional out CMMMaterialReplicationInfo ReplicateToMRI)
{
    local MaterialMapping MM;
    local MaterialInstanceConstant MIC;
    local MaterialInterface Mat;
    local int Idx;
    local MeshComponent TargetComp;
    local CMMMaterialCache MatCache;

    NumMappingsToApply = Clamp(NumMappingsToApply, 0, `MAX_MATERIAL_MAPPINGS);

    `cmmlog("NumMappingsToApply=" $ NumMappingsToApply $ " bReplicate=" $ bReplicate $ " ReplicateToMRI=" $ ReplicateToMRI);

    MatCache = CMMPlayerController(Owner.GetALocalPlayerController()).GetMatCache();

    `cmmlog("MatCache = " $ MatCache);

    for (Idx = 0; Idx < NumMappingsToApply; ++Idx)
    {
        MM = MaterialMappings[Idx];
        TargetComp = GetTargetMeshComponent(MM.TargetCompID);

        if ((TargetComp == None) || MM.MaterialName == "")
        {
            continue;
        }

        Mat = MatCache.GetMaterialByID(MM.MaterialID);
        MIC = new(self) class'MaterialInstanceConstant';
        MIC.SetParent(Mat);
        `cmmlog("setting MIC: " $ MIC $ " on: " $ TargetComp $ " index: " $ MM.MaterialIndex $ " MaterialName: " $ MM.MaterialName);
        TargetComp.SetMaterial(MM.MaterialIndex, MIC);

        if (bReplicate && (ReplicateToMRI != None))
        {
            ReplicateToMRI.ReplMatMappings[Idx].TargetCompID = MM.TargetCompID;
            ReplicateToMRI.ReplMatMappings[Idx].MaterialIndex = MM.MaterialIndex;
            ReplicateToMRI.ReplMatMappings[Idx].MaterialID = MM.MaterialID;
        }
    }
}

DefaultProperties
{
}
