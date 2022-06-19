class CMMReplicatedSkeletalMeshActor extends SkeletalMeshActor;

var repnotify CMMMaterialReplicationInfo MaterialReplicationInfo;
var CMMCustomMaterialContainer CustomMaterialContainer;

replication
{
    if (Role == ROLE_Authority)
        MaterialReplicationInfo;
}

simulated event PostBeginPlay()
{
    local int Idx;
    local int ReplCount;

    super.PostBeginPlay();

    MaterialReplicationInfo = Spawn(class'CMMMaterialReplicationInfo', self,, vect(0,0,0), rot(0,0,0));

    for (Idx = 0; Idx < `MAX_MATERIAL_MAPPINGS; ++Idx)
    {
        if (CustomMaterialContainer.MaterialMappings[Idx].TargetComp != None)
        {
            MaterialReplicationInfo.ReplMatMappings[Idx].TargetComp = CustomMaterialContainer.MaterialMappings[Idx].TargetComp;
            MaterialReplicationInfo.ReplMatMappings[Idx].MaterialIndex = CustomMaterialContainer.MaterialMappings[Idx].MaterialIndex;
            MaterialReplicationInfo.ReplMatMappings[Idx].MaterialName = CustomMaterialContainer.MaterialMappings[Idx].MaterialName;
            ReplCount++;
        }
    }
    MaterialReplicationInfo.ReplCount = ReplCount;
}

simulated event ReplicatedEvent(name VarName)
{
    local int Idx;

    `cmmlog("VarName = " $ VarName);

    if (VarName == 'MaterialReplicationInfo')
    {
        `cmmlog(self $ " got MaterialReplicationInfo");

        for (Idx = 0; Idx < MaterialReplicationInfo.ReplCount; ++Idx)
        {
            `cmmlog("TargetComp = " $ MaterialReplicationInfo.ReplMatMappings[Idx].TargetComp);
            `cmmlog("MaterialIndex = " $ MaterialReplicationInfo.ReplMatMappings[Idx].MaterialIndex);
            `cmmlog("MaterialName = " $ MaterialReplicationInfo.ReplMatMappings[Idx].MaterialName);

            CustomMaterialContainer.MaterialMappings[Idx].TargetComp = MaterialReplicationInfo.ReplMatMappings[Idx].TargetComp;
            CustomMaterialContainer.MaterialMappings[Idx].MaterialIndex = MaterialReplicationInfo.ReplMatMappings[Idx].MaterialIndex;
            CustomMaterialContainer.MaterialMappings[Idx].MaterialName = MaterialReplicationInfo.ReplMatMappings[Idx].MaterialName;
        }

        CustomMaterialContainer.ApplyMaterials(MaterialReplicationInfo.ReplCount, False);
    }
    else
    {
        Super.ReplicatedEvent(VarName);
    }
}

DefaultProperties
{
    Begin Object Class=CMMCustomMaterialContainer Name=CustomMaterialContainer0
    End Object
    CustomMaterialContainer=CustomMaterialContainer0
    Components.Add(CustomMaterialContainer0)
}
