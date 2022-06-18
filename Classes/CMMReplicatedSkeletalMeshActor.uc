class CMMReplicatedSkeletalMeshActor extends SkeletalMeshActor;

var repnotify CMMMaterialReplicationInfo MaterialReplicationInfo;
var CMMCustomMaterialContainer CustomMaterialContainer;

replication
{
    if (bNetDirty)
        MaterialReplicationInfo;
}

simulated event ReplicatedEvent(name VarName)
{
    local int Idx;

    if (VarName == 'MaterialReplicationInfo')
    {
        `cmmlog(self $ " got MaterialReplicationInfo");

        for (Idx = 0; Idx < MaterialReplicationInfo.ReplCount; ++Idx)
        {
            `cmmlog("TargetComp = " $ MaterialReplicationInfo.ReplicatedMaterialMappings[Idx].TargetComp);
            `cmmlog("MaterialIndex = " $ MaterialReplicationInfo.ReplicatedMaterialMappings[Idx].MaterialIndex);
            `cmmlog("MaterialName = " $ MaterialReplicationInfo.ReplicatedMaterialMappings[Idx].MaterialName);

            CustomMaterialContainer.MaterialMappings[Idx].TargetComp = MaterialReplicationInfo.ReplicatedMaterialMappings[Idx].TargetComp;
            CustomMaterialContainer.MaterialMappings[Idx].MaterialIndex = MaterialReplicationInfo.ReplicatedMaterialMappings[Idx].MaterialIndex;
            CustomMaterialContainer.MaterialMappings[Idx].MaterialName = MaterialReplicationInfo.ReplicatedMaterialMappings[Idx].MaterialName;
        }

        CustomMaterialContainer.ApplyMaterials(MaterialReplicationInfo.ReplCount, False);
    }
    else
    {
        Super.ReplicatedEvent(VarName);
    }
}
