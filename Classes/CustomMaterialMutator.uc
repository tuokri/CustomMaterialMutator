class CustomMaterialMutator extends ROMutator
    config(Mutator_CustomMaterial);

// Map(s) that contain our custom materials.
var name LevelsToPreload[`MAX_PRELOAD_LEVELS];

var array<Actor> TestActors;

function PreBeginPlay()
{
    ROGameInfo(WorldInfo.Game).PlayerControllerClass = class'CMMPlayerController';

    PreloadLevels();
    PreloadCustomMaterials();

    super.PreBeginPlay();

    `cmmlog("mutator init");
}

function NotifyLogin(Controller NewPlayer)
{
    // PlayerController(NewPlayer).ClientMessage("Hello from CustomMaterialMutator");

    CMMPlayerController(NewPlayer).ClientPreloadLevels();
    CMMPlayerController(NewPlayer).ClientPreloadCustomMaterials();

    `cmmlog(NewPlayer $ " logged in");

    super.NotifyLogin(NewPlayer);
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
            `cmmlog("Levels[" $ Idx $ "]: " $ LevelsToPreload[Idx]);
            if (LevelsToPreload[Idx] != '')
            {
                LevelsArr.AddItem(LevelsToPreload[Idx]);
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
    local Material Mat;
    local ROMapInfo ROMI;
    local Actor A;
    local CMMCustomMaterialContainer CMC;
    local int Idx;

    // Wait until PrepareMapChange() finishes (it's async)...
    if (WorldInfo.IsPreparingMapChange())
    {
        SetTimer(0.01, False, NameOf(DelayedPreloadCustomMaterials));
    }
    else
    {
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
    }
}

function ROMutate(string MutateString, PlayerController Sender, out string ResultMsg)
{
    local array<string> Args;
    local Actor A;
    local Material Mat;
    local MaterialInstanceConstant MIC;
    local string MatName;
    local CMMReplicatedMaterialMapping ReplMM;

    Args = SplitString(MutateString);

    // Example commands:
    // romutate spawn,static,VNTE-MaterialContainer.BlinkingTestMat
    // romutate spawn,skeletal,VNTE-MaterialContainer.TestMat
    // romutate spawn,skeletal,PackageName.MaterialName
    if (Locs(Args[0]) == "spawn")
    {
        MatName = Args[2];
        Mat = Material(DynamicLoadObject(MatName, class'Material'));
        MIC = new(self) class'MaterialInstanceConstant';
        MIC.SetParent(Mat);
        SpawnTestActor(Sender, Locs(Args[1]), MIC, MatName);
    }
    // romutate setmat,VNTE-MaterialContainer.TestMat
    // romutate setmat,PackageName.MaterialName
    if (Locs(Args[0]) == "setmat")
    {
        MatName = Args[1];
        Mat = Material(DynamicLoadObject(MatName, class'Material'));

        if (Mat == None)
        {
            `cmmlog("error, could not load material: " $ MatName);
            return;
        }

        ForEach TestActors(A)
        {
            MIC = new(self) class'MaterialInstanceConstant';
            if (MIC == None)
            {
                `cmmlog("error, could not create MIC from " $ Mat);
                return;
            }

            MIC.SetParent(Mat);
            `cmmlog("setting " $ A $ " material to: " $ MIC);

            if (A.IsA('CMMStaticTestActor'))
            {
                CMMStaticTestActor(A).StaticMeshComponent.SetMaterial(0, MIC);
                ReplMM.TargetComp = CMMStaticTestActor(A).StaticMeshComponent;
                ReplMM.MaterialIndex = 0;
                ReplMM.MaterialName = MatName;
                CMMStaticTestActor(A).MaterialReplicationInfo.ReplMatMappings[0] = ReplMM;
                CMMStaticTestActor(A).MaterialReplicationInfo.ReplCount = 1;
                CMMStaticTestActor(A).MaterialReplicationInfo.bNetDirty = True; // TODO: this should happen automatically.
            }
            else if (A.IsA('CMMSkeletalTestActor'))
            {
                CMMSkeletalTestActor(A).SkeletalMeshComponent.SetMaterial(0, MIC);
                ReplMM.TargetComp = CMMSkeletalTestActor(A).SkeletalMeshComponent;
                ReplMM.MaterialIndex = 0;
                ReplMM.MaterialName = MatName;
                CMMSkeletalTestActor(A).MaterialReplicationInfo.ReplMatMappings[0] = ReplMM;
                CMMSkeletalTestActor(A).MaterialReplicationInfo.ReplCount = 1;
                CMMSkeletalTestActor(A).MaterialReplicationInfo.bNetDirty = True; // TODO: this should happen automatically.
            }

            A.ForceNetRelevant();
        }
    }
    // romutate spawn2
    if (Locs(Args[0]) == "spawn2")
    {
        SpawnTestActor(Sender, "nodynamicmaterial");
    }

    super.ROMutate(MutateString, Sender, ResultMsg);
}

simulated function SpawnTestActor(PlayerController Player, string Type, optional MaterialInstanceConstant MaterialToApply,
    optional string ReplicatedMaterialName)
{
    local CMMReplicatedMaterialMapping ReplMM;
    local Actor SpawnedActor;
    local vector Loc;

    Loc = Player.Pawn.Location + (Normal(vector(Player.Pawn.Rotation)) * 100);
    `cmmlog("spawning test actor at " $ Loc);
    if (MaterialToApply != None)
    {
        Player.ClientMessage("[CustomMaterialMutator]: spawning test actor at: " $ Loc $ " with material: " $ MaterialToApply);
    }

    if (Type == "static")
    {
        SpawnedActor = Spawn(class'CMMStaticTestActor', Self,, Loc, Player.Pawn.Rotation);
        CMMStaticTestActor(SpawnedActor).StaticMeshComponent.SetMaterial(0, MaterialToApply);
        ReplMM.TargetComp = CMMStaticTestActor(SpawnedActor).StaticMeshComponent;
        ReplMM.MaterialIndex = 0;
        ReplMM.MaterialName = ReplicatedMaterialName;
        CMMStaticTestActor(SpawnedActor).MaterialReplicationInfo.ReplMatMappings[0] = ReplMM;
        CMMStaticTestActor(SpawnedActor).MaterialReplicationInfo.ReplCount = 1;
        CMMStaticTestActor(SpawnedActor).MaterialReplicationInfo.bNetDirty = True; // TODO: this should happen automatically.
    }
    else if (Type == "skeletal")
    {
        SpawnedActor = Spawn(class'CMMSkeletalTestActor', Self,, Loc, Player.Pawn.Rotation);
        CMMSkeletalTestActor(SpawnedActor).SkeletalMeshComponent.SetMaterial(0, MaterialToApply);
        ReplMM.TargetComp = CMMSkeletalTestActor(SpawnedActor).SkeletalMeshComponent;
        ReplMM.MaterialIndex = 0;
        ReplMM.MaterialName = ReplicatedMaterialName;
        CMMSkeletalTestActor(SpawnedActor).MaterialReplicationInfo.ReplMatMappings[0] = ReplMM;
        CMMSkeletalTestActor(SpawnedActor).MaterialReplicationInfo.ReplCount = 1;
        CMMSkeletalTestActor(SpawnedActor).MaterialReplicationInfo.bNetDirty = True; // TODO: this should happen automatically.
    }
    else if (Type == "nodynamicmaterial")
    {
        SpawnedActor = Spawn(class'CMMSkeletalTestActor2', Self,, Loc, Player.Pawn.Rotation);
        Player.ClientMessage("[CustomMaterialMutator]: spawning test actor at: " $ Loc);
    }
    else
    {
        `cmmlog("invalid type: " $ Type);
    }

    if (SpawnedActor != None)
    {
        SpawnedActor.ForceNetRelevant();
        TestActors.AddItem(SpawnedActor);
    }
}

DefaultProperties
{
    LevelsToPreload(0)="VNTE-MaterialContainer2"
}
