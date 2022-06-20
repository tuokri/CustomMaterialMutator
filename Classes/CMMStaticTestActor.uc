class CMMStaticTestActor extends CMMReplicatedStaticMeshActor;

var DynamicLightEnvironmentComponent LightEnvironment;

DefaultProperties
{
    Begin Object Class=DynamicLightEnvironmentComponent Name=MyLightEnvironment
        bEnabled=True
        TickGroup=TG_DuringAsyncWork
        bSynthesizeSHLight=True
        bIsCharacterLightEnvironment=True
        bDynamic=True
    End Object
    Components.Add(MyLightEnvironment)
    LightEnvironment=MyLightEnvironment

    Begin Object Name=StaticMeshComponent0
        StaticMesh=StaticMesh'EngineMeshes.Sphere'
        Materials.Empty
        CollideActors=False
        BlockActors=False
        BlockZeroExtent=False
        BlockNonZeroExtent=False
        BlockRigidBody=False
    End Object

    Begin Object Name=CustomMaterialContainer0
        MeshComponentMappings(0)=(TargetCompID=0,TargetComp=StaticMeshComponent0)
    End Object

    bStatic=False
    bNoDelete=False
    LifeSpan=0

    bGameRelevant=True
    bUpdateSimulatedPosition=True
    RemoteRole=ROLE_SimulatedProxy
}
