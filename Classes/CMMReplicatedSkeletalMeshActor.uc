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
    local int MaterialID;

    super.PostBeginPlay();

    MaterialReplicationInfo = Spawn(class'CMMMaterialReplicationInfo', self,, vect(0,0,0), rot(0,0,0));

    for (Idx = 0; Idx < `MAX_MATERIAL_MAPPINGS; ++Idx)
    {
        MaterialReplicationInfo.ReplMatMappings[Idx].TargetCompID = CustomMaterialContainer.MaterialMappings[Idx].TargetCompID;
        MaterialReplicationInfo.ReplMatMappings[Idx].MaterialIndex = CustomMaterialContainer.MaterialMappings[Idx].MaterialIndex;
        MaterialID = CMMPlayerController(GetALocalPlayerController()).GetMatCache().GetMaterialID(CustomMaterialContainer.MaterialMappings[Idx].MaterialName);
        MaterialReplicationInfo.ReplMatMappings[Idx].MaterialID = MaterialID;
    }
    MaterialReplicationInfo.ReplCount = `MAX_MATERIAL_MAPPINGS;
}

simulated event Destroyed()
{
    super.Destroyed();

    MaterialReplicationInfo.Destroy();
    MaterialReplicationInfo = None;
}

simulated event ReplicatedEvent(name VarName)
{
    local int Idx;

    // `cmmlog("VarName = " $ VarName);

    if (VarName == 'MaterialReplicationInfo')
    {
        `cmmlog(self $ " got MaterialReplicationInfo");

        for (Idx = 0; Idx < MaterialReplicationInfo.ReplCount; ++Idx)
        {
            `cmmlog("TargetComp    = " $ CustomMaterialContainer.GetTargetMeshComponent(MaterialReplicationInfo.ReplMatMappings[Idx].TargetCompID));
            `cmmlog("TargetCompID  = " $ MaterialReplicationInfo.ReplMatMappings[Idx].TargetCompID);
            `cmmlog("MaterialIndex = " $ MaterialReplicationInfo.ReplMatMappings[Idx].MaterialIndex);
            `cmmlog("MaterialID    = " $ MaterialReplicationInfo.ReplMatMappings[Idx].MaterialID);
            `cmmlog("MaterialName  = " $ CMMPlayerController(
                GetALocalPlayerController()).GetMatCache().GetMaterialName(
                MaterialReplicationInfo.ReplMatMappings[Idx].MaterialID));

            CustomMaterialContainer.MaterialMappings[Idx].TargetCompID = MaterialReplicationInfo.ReplMatMappings[Idx].TargetCompID;
            CustomMaterialContainer.MaterialMappings[Idx].MaterialIndex = MaterialReplicationInfo.ReplMatMappings[Idx].MaterialIndex;
            CustomMaterialContainer.MaterialMappings[Idx].MaterialID = MaterialReplicationInfo.ReplMatMappings[Idx].MaterialID;
            CustomMaterialContainer.MaterialMappings[Idx].MaterialName = CMMPlayerController(
                GetALocalPlayerController()).GetMatCache().GetMaterialName(
                MaterialReplicationInfo.ReplMatMappings[Idx].MaterialID);
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
