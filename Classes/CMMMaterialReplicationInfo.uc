class CMMMaterialReplicationInfo extends ReplicationInfo;

struct CMMReplicatedMaterialMapping
{
    var MeshComponent TargetComp;
    var byte MaterialIndex;
    var string MaterialName; // TODO: Optimize this to a byte/int?
};

var byte ReplCount;
var CMMReplicatedMaterialMapping ReplMatMappings[`MAX_MATERIAL_MAPPINGS];

DefaultProperties
{
}
