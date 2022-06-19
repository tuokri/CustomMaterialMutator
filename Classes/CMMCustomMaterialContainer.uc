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
    var byte TargetCompID;
    // Material slot in the target MeshComponent.
    var int MaterialIndex;
    // Full name of the material.
    var string MaterialName;
};

var MaterialMapping MaterialMappings[`MAX_MATERIAL_MAPPINGS];
var array<MeshComponentMapping> MeshComponentMappings;

function MeshComponent GetTargetMeshComponent(byte MeshCompID)
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

function byte GetTargetMeshComponentID(MeshComponent MeshComp)
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

// TODO: instead of calling DynamicLoadObject here, do the dynamic loading
// at startup for all custom materials, then just fetch the reference to the
// material here and apply it on the target mesh component.
simulated function ApplyMaterials(optional int NumMappingsToApply = `MAX_MATERIAL_MAPPINGS,
    optional bool bReplicate = False, optional out CMMMaterialReplicationInfo MRI)
{
    local MaterialMapping MM;
    local MaterialInstanceConstant MIC;
    local Material Mat;
    local int Idx;
    local MeshComponent TargetComp;

    NumMappingsToApply = Clamp(NumMappingsToApply, 0, `MAX_MATERIAL_MAPPINGS);

    `cmmlog("NumMappingsToApply=" $ NumMappingsToApply $ " bReplicate=" $ bReplicate $ " MRI=" $ MRI);

    for (Idx = 0; Idx < NumMappingsToApply; ++Idx)
    {
        MM = MaterialMappings[Idx];
        TargetComp = GetTargetMeshComponent(MM.TargetCompID);

        if ((TargetComp == None) || MM.MaterialName == "")
        {
            continue;
        }

        Mat = Material(DynamicLoadObject(MM.MaterialName, class'Material'));
        MIC = new(self) class'MaterialInstanceConstant';
        MIC.SetParent(Mat);
        `cmmlog("setting MIC: " $ MIC $ " on: " $ TargetComp $ " index: " $ MM.MaterialIndex);
        TargetComp.SetMaterial(MM.MaterialIndex, MIC);

        if (bReplicate && (MRI != None))
        {
            MRI.ReplMatMappings[Idx].TargetCompID = MM.TargetCompID;
            MRI.ReplMatMappings[Idx].MaterialIndex = MM.MaterialIndex;
            MRI.ReplMatMappings[Idx].MaterialName = MM.MaterialName;
        }
    }
}

DefaultProperties
{
}
