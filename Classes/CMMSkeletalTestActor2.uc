class CMMSkeletalTestActor2 extends CMMReplicatedSkeletalMeshActor;

simulated event PostBeginPlay()
{
    super.PostBeginPlay();

    CustomMaterialContainer.ApplyMaterials(1, True, MaterialReplicationInfo);
}

DefaultProperties
{
    Begin Object Name=MyLightEnvironment
        bSynthesizeSHLight=True
        bIsCharacterLightEnvironment=True
        bDynamic=True
    End Object

    Begin Object Name=SkeletalMeshComponent0
        SkeletalMesh=SkeletalMesh'CHR_VN_AUS_Heads.Mesh.AUS_Head10_Mesh'
        // Can't set this here because we get an external reference error on compilation.
        // Materials(0)='VNTE-MaterialContainer2.TestMat'
        // Materials(1)='VNTE-MaterialContainer2.TestMat1'
        // Materials(2)='VNTE-MaterialContainer2.TestMatasdasdasd'
        Materials.Empty
        LightEnvironment=MyLightEnvironment
        bCastDynamicShadow=True
        bAcceptsDynamicLights=True
        CastShadow=True
    End Object

    Begin Object Name=CustomMaterialContainer0
        MaterialMappings(0)=(TargetComp=SkeletalMeshComponent0,MaterialIndex=0,MaterialName="VNTE-MaterialContainer2.TestMat")
        // MaterialMappings(1)=(TargetComp=SkeletalMeshComponent0,MaterialIndex=1,MaterialName="VNTE-MaterialContainer2.TestMat1")
        // MaterialMappings(2)=(TargetComp=SkeletalMeshComponent0,MaterialIndex=2,MaterialName="VNTE-MaterialContainer2.TestMatasdasdasd")
    End Object

    bNoDelete=False
    LifeSpan=0

    bGameRelevant=True
    bUpdateSimulatedPosition=True
    RemoteRole=ROLE_SimulatedProxy
}
