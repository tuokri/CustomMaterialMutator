class CMMCustomMaterialContainer extends ActorComponent
    dependson(CMMMaterialReplicationInfo);

struct MaterialMapping
{
    var MeshComponent TargetComp;
    var int MaterialIndex;
    var string MaterialName;
};

var MaterialMapping MaterialMappings[`MAX_MATERIAL_MAPPINGS];

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

    NumMappingsToApply = Clamp(NumMappingsToApply, 0, `MAX_MATERIAL_MAPPINGS);

    `cmmlog("NumMappingsToApply=" $ NumMappingsToApply $ " bReplicate=" $ bReplicate $ " MRI=" $ MRI);

    for (Idx = 0; Idx < NumMappingsToApply; ++Idx)
    {
        MM = MaterialMappings[Idx];
        if (MM.TargetComp == None)
        {
            continue;
        }

        Mat = Material(DynamicLoadObject(MM.MaterialName, class'Material'));
        MIC = new(self) class'MaterialInstanceConstant';
        MIC.SetParent(Mat);
        `cmmlog("setting MIC: " $ MIC $ " on: " $ MM.TargetComp $ " index: " $ MM.MaterialIndex);
        MM.TargetComp.SetMaterial(MM.MaterialIndex, MIC);

        if (bReplicate && MRI != None)
        {
            MRI.ReplMatMappings[Idx].TargetComp = MM.TargetComp;
            MRI.ReplMatMappings[Idx].MaterialIndex = MM.MaterialIndex;
            MRI.ReplMatMappings[Idx].MaterialName = MM.MaterialName;
        }
    }
}

DefaultProperties
{
}
