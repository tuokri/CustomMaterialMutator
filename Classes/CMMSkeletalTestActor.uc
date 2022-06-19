class CMMSkeletalTestActor extends CMMReplicatedSkeletalMeshActor;

DefaultProperties
{
    Begin Object Name=MyLightEnvironment
        bSynthesizeSHLight=True
        bIsCharacterLightEnvironment=True
        bDynamic=True
    End Object

    Begin Object Name=SkeletalMeshComponent0
        SkeletalMesh=SkeletalMesh'CHR_VN_AUS_Heads.Mesh.AUS_Head10_Mesh'
        Materials.Empty
        LightEnvironment=MyLightEnvironment
        bCastDynamicShadow=True
        bAcceptsDynamicLights=True
        CastShadow=True
    End Object
    bNoDelete=False
    LifeSpan=0

    Begin Object Name=CustomMaterialContainer0
        MeshComponentMappings(0)=(TargetCompID=0,TargetComp=SkeletalMeshComponent0)
    End Object

    bGameRelevant=True
    bUpdateSimulatedPosition=True
    RemoteRole=ROLE_SimulatedProxy
}
