class CMMMaterialReplicationInfo extends ReplicationInfo;

struct CMMReplicatedMaterialMapping
{
    var MeshComponent TargetComp;   // MeshComponent to apply the material to.
    var byte MaterialIndex;         // Material slot in TargetComp.
    var string MaterialName;        // TODO: Optimize this to an int and get the name from CMMMaterialCache.
};

// Indicates how many ReplMatMappings entires were changed and should be applied after replication.
var byte ReplCount;
var CMMReplicatedMaterialMapping ReplMatMappings[`MAX_MATERIAL_MAPPINGS];

replication
{
    if (bNetDirty)
        ReplMatMappings, ReplCount;
}

DefaultProperties
{
}
