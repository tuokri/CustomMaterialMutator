class CMMMaterialReplicationInfo extends ReplicationInfo;

struct CMMReplicatedMaterialMapping
{
    // MeshComponent ID to apply the material to. References TargetCompID in CMMCustomMaterialContainer::MeshComponentMappings.
    var byte TargetCompID;
    // Material slot in TargetComp mesh.
    var byte MaterialIndex;
    // References index in CMMMaterialCache::CachedMats array.
    var int MaterialID;
};

// Indicates how many ReplMatMappings entires were changed and should be applied after replication.
var byte ReplCount;
// Replicated CMMReplicatedMaterialMapping entries to apply.
var CMMReplicatedMaterialMapping ReplMatMappings[`MAX_MATERIAL_MAPPINGS];

replication
{
    if (bNetDirty)
        ReplMatMappings, ReplCount;
}

DefaultProperties
{
}
