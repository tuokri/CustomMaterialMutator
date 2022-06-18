class CMMStaticTestActor extends StaticMeshActor;

DefaultProperties
{
    Begin Object Name=StaticMeshComponent0
        StaticMesh=StaticMesh'EngineMeshes.Sphere'
        CollideActors=False
        BlockActors=False
        BlockZeroExtent=False
        BlockNonZeroExtent=False
        BlockRigidBody=False
    End Object

    bStatic=False
    bNoDelete=False
    LifeSpan=0

    bGameRelevant=True
    bUpdateSimulatedPosition=True
    RemoteRole=ROLE_SimulatedProxy
}
