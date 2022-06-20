class CMMPlayerController extends ROPlayerController;

// Client-side material cache.
// TODO: would be simpler to have a single cache in GameInfo.
var CMMMaterialCache CustomMaterialCache;

function CMMMaterialCache GetMatCache()
{
    if (WorldInfo.NetMode == NM_DedicatedServer)
    {
        return GetCMM().MaterialCache;
    }
    else
    {
        return CustomMaterialCache;
    }
}

simulated event PreBeginPlay()
{
    super.PreBeginPlay();

    if (WorldInfo.NetMode == NM_Client || WorldInfo.NetMode == NM_Standalone)
    {
        CustomMaterialCache = new(self) class'CMMMaterialCache';
        if (CustomMaterialCache == None)
        {
            `cmmlog("** !ERROR! ** cannot create CMMMaterialCache: ");
        }
    }
}

simulated function CustomMaterialMutator GetCMM()
{
    return CustomMaterialMutator(WorldInfo.Game.BaseMutator);
}

reliable client function ClientPreloadCustomMaterials()
{
    `cmmlog("PreloadCustomMaterials starting on " $ self);
    PreloadCustomMaterials();
    `cmmlog("PreloadCustomMaterials done on " $ self);
}

reliable client function ClientPreloadLevels()
{
    `cmmlog("PreLoadLevels starting on " $ self);
    PreLoadLevels();
    `cmmlog("PreLoadLevels done on " $ self);
}

// Preload level(s) that contain custom materials.
function PreloadLevels()
{
    DelayedPreloadLevels();
}

function DelayedPreloadLevels()
{
    local int Idx;
    local array<name> LevelsArr;

    if (WorldInfo.IsPreparingMapChange())
    {
        SetTimer(0.01, False, NameOf(DelayedPreloadLevels));
    }
    else
    {
        for (Idx = 0; Idx < `MAX_PRELOAD_LEVELS; Idx++)
        {
            `cmmlog("Levels[" $ Idx $ "]: " $ class'CustomMaterialMutator'.default.LevelsToPreload[Idx]);
            if (class'CustomMaterialMutator'.default.LevelsToPreload[Idx] != '')
            {
                LevelsArr.AddItem(class'CustomMaterialMutator'.default.LevelsToPreload[Idx]);
            }
        }
        WorldInfo.PrepareMapChange(LevelsArr);
    }
}

// Preload the actual materials.
function PreloadCustomMaterials()
{
    DelayedPreloadCustomMaterials();
}

function DelayedPreloadCustomMaterials()
{
    // local Material Mat;
    // local ROMapInfo ROMI;
    // local Actor A;
    // local CMMCustomMaterialContainer CMC;
    // local int Idx;

    // Wait until PrepareMapChange() finishes (it's async)...
    if (WorldInfo.IsPreparingMapChange())
    {
        SetTimer(0.01, False, NameOf(DelayedPreloadCustomMaterials));
    }
    else
    {
        CustomMaterialCache.LoadMaterials();

        /*
        ROMI = ROMapInfo(WorldInfo.GetMapInfo());

        // TODO:
        // Yikes, triple nested loop... Try to find a better way of doing this.
        // Predefined hard-coded list of materials to preload?
        // Also, this will not load materials for actors that are not
        // present in the level at the time of this call.
        ForEach WorldInfo.AllActors(class'Actor', A)
        {
            ForEach A.ComponentList(class'CMMCustomMaterialContainer', CMC)
            {
                `cmmlog("preloading materials for " $ A $ " " $ CMC);
                for (Idx = 0; Idx < `MAX_MATERIAL_MAPPINGS; Idx++)
                {
                    if (CMC.MaterialMappings[Idx].MaterialName != "")
                    {
                        Mat = Material(DynamicLoadObject(CMC.MaterialMappings[Idx].MaterialName, class'Material'));
                        `cmmlog("preloaded " $ Mat);
                        ROMI.SharedContentReferences.AddItem(Mat);
                    }
                }
            }
        }
        */
    }
}

simulated exec function SpawnTestActor(string Type, string MaterialName)
{
    ServerSpawnTestActor(Type, MaterialName);
}

reliable server function ServerSpawnTestActor(string Type, string MaterialName)
{
    local CMMReplicatedMaterialMapping ReplMM;
    local Actor SpawnedActor;
    local vector Loc;
    local Material Mat;
    local MaterialInstanceConstant MIC;

    Mat = GetMatCache().GetMaterialByName(MaterialName);
    MIC = new(self) class'MaterialInstanceConstant';
    MIC.SetParent(Mat);

    Loc = Pawn.Location + (Normal(vector(Pawn.Rotation)) * 100);
    `cmmlog("spawning test actor at " $ Loc);
    if (MIC != None)
    {
        ClientMessage("[CustomMaterialMutator]: spawning test actor at: " $ Loc $ " with material: " $ MIC);
    }

    if (Type == "static")
    {
        SpawnedActor = Spawn(class'CMMStaticTestActor', GetCMM(),, Loc, Pawn.Rotation);
        CMMStaticTestActor(SpawnedActor).StaticMeshComponent.SetMaterial(0, MIC);
        ReplMM.TargetCompID = CMMStaticTestActor(SpawnedActor).CustomMaterialContainer.GetTargetMeshComponentID(
            CMMStaticTestActor(SpawnedActor).StaticMeshComponent);
        ReplMM.MaterialIndex = 0;
        ReplMM.MaterialID = GetMatCache().GetMaterialID(MaterialName);
        CMMStaticTestActor(SpawnedActor).MaterialReplicationInfo.ReplMatMappings[0] = ReplMM;
        CMMStaticTestActor(SpawnedActor).MaterialReplicationInfo.ReplCount = 1;
        CMMStaticTestActor(SpawnedActor).MaterialReplicationInfo.bNetDirty = True; // TODO: This should be automatic?
    }
    else if (Type == "skeletal")
    {
        SpawnedActor = Spawn(class'CMMSkeletalTestActor', GetCMM(),, Loc, Pawn.Rotation);
        CMMSkeletalTestActor(SpawnedActor).SkeletalMeshComponent.SetMaterial(0, MIC);
        ReplMM.TargetCompID = CMMSkeletalTestActor(SpawnedActor).CustomMaterialContainer.GetTargetMeshComponentID(
            CMMSkeletalTestActor(SpawnedActor).SkeletalMeshComponent);
        ReplMM.MaterialIndex = 0;
        ReplMM.MaterialID = GetMatCache().GetMaterialID(MaterialName);
        CMMSkeletalTestActor(SpawnedActor).MaterialReplicationInfo.ReplMatMappings[0] = ReplMM;
        CMMSkeletalTestActor(SpawnedActor).MaterialReplicationInfo.ReplCount = 1;
        CMMSkeletalTestActor(SpawnedActor).MaterialReplicationInfo.bNetDirty = True; // TODO: This should be automatic?
    }
    else if (Type == "nodynamicmaterial")
    {
        SpawnedActor = Spawn(class'CMMSkeletalTestActor2', GetCMM(),, Loc, Pawn.Rotation);
        ClientMessage("[CustomMaterialMutator]: spawning test actor at: " $ Loc);
    }
    else
    {
        `cmmlog("invalid type: " $ Type);
    }

    if (SpawnedActor != None)
    {
        SpawnedActor.ForceNetRelevant();
        GetCMM().TestActors.AddItem(SpawnedActor);
    }
}
