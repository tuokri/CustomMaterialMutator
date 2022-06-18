class CMMReplicatedSkeletalMeshActor extends SkeletalMeshActor;

// replication
// {
//     if (bNetDirty && Role==ROLE_Authority)
//         MaterialReplicationInfo;
// }

var repnotify CMMMaterialReplicationInfo MaterialReplicationInfo;
var CMMCustomMaterialContainer CustomMaterialContainer;

simulated event ReplicatedEvent(name VarName)
{
    local int Idx;

    if (VarName == 'MaterialReplicationInfo')
    {
        for (Idx = 0; Idx < MaterialReplicationInfo.ReplCount; ++Idx)
        {
            CustomMaterialContainer.MaterialMappings[Idx].TargetComp = MaterialReplicationInfo.ReplicatedMaterialMappings[Idx].TargetComp;
            CustomMaterialContainer.MaterialMappings[Idx].MaterialIndex = MaterialReplicationInfo.ReplicatedMaterialMappings[Idx].MaterialIndex;
            CustomMaterialContainer.MaterialMappings[Idx].MaterialName = MaterialReplicationInfo.ReplicatedMaterialMappings[Idx].MaterialName;
        }

        CustomMaterialContainer.ApplyMaterials(MaterialReplicationInfo.ReplCount);
    }
    else
    {
        Super.ReplicatedEvent(VarName);
    }
}
