class CMMMaterialReplicationInfo extends ReplicationInfo;

struct CMMReplicatedMaterialMapping
{
    // MeshComponent ID to apply the material to. Refers to TargetCompID in MeshComponentMapping.
    var byte TargetCompID;
    // Material slot in TargetComp.
    var byte MaterialIndex;
    // TODO: Optimize this to an int and get the name from CMMMaterialCache.
    var string MaterialName;
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
