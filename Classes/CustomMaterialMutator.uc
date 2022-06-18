class CustomMaterialMutator extends ROMutator
    config(Mutator_CustomMaterial);

// Map(s) that contain our custom materials.
var array<name> LevelsToPreload;

var array<Actor> TestActors;

function PreBeginPlay()
{
    PreloadLevels(LevelsToPreload);
    PreloadCustomMaterials();

    super.PreBeginPlay();

    `cmmlog("mutator init");
}

function NotifyLogin(Controller NewPlayer)
{
    ClientPreloadLevels(LevelsToPreload);
    ClientPreloadCustomMaterials();

    super.NotifyLogin(NewPlayer);
}

// Preload level(s) that contain custom materials.
function PreloadLevels(array<name> Levels)
{
    local int Idx;

    for (Idx = 0; Idx < Levels.Length; Idx++)
    {
        `cmmlog("Levels[" $ Idx $ "]: " $ Levels[Idx]);
    }
    WorldInfo.PrepareMapChange(Levels);
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
    local CMMCustomMaterialContainer CMM;
    local MaterialMapping MM;

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
            ForEach A.ComponentList(class'CMMCustomMaterialContainer', CMM)
            {
                `cmmlog("preloading materials for " $ A $ " " $ CMM);
                ForEach CMM.MaterialMappings(MM)
                {
                    Mat = Material(DynamicLoadObject(MM.MaterialName, class'Material'));
                    `cmmlog("preloaded " $ Mat);
                    ROMI.SharedContentReferences.AddItem(Mat);
                }
            }
        }
    }
}

reliable client function ClientPreloadCustomMaterials()
{
    PreloadCustomMaterials();
}

reliable client function ClientPreloadLevels(array<name> Levels)
{
    PreLoadLevels(Levels);
}

function ROMutate(string MutateString, PlayerController Sender, out string ResultMsg)
{
    local array<string> Args;
    local Actor A;
    local Material Mat;
    local MaterialInstanceConstant MIC;

    Args = SplitString(MutateString);

    // Example commands:
    // romutate spawn,static,VNTE-MaterialContainer.BlinkingTestMat
    // romutate spawn,skeletal,VNTE-MaterialContainer.TestMat
    // romutate spawn,skeletal,PackageName.MaterialName
    if (Locs(Args[0]) == "spawn")
    {
        Mat = Material(DynamicLoadObject(Args[2], class'Material'));
        MIC = new(self) class'MaterialInstanceConstant';
        MIC.SetParent(Mat);
        SpawnTestActor(Sender, Locs(Args[1]), MIC);
    }
    // romutate setmat,VNTE-MaterialContainer.TestMat
    // romutate setmat,PackageName.MaterialName
    if (Locs(Args[0]) == "setmat")
    {
        Mat = Material(DynamicLoadObject(Args[1], class'Material'));
        ForEach TestActors(A)
        {
            MIC = new(self) class'MaterialInstanceConstant';
            MIC.SetParent(Mat);
            `cmmlog("setting " $ A $ " material to: " $ MIC);

            if (A.IsA('CMMStaticTestActor'))
            {
                CMMStaticTestActor(A).StaticMeshComponent.SetMaterial(0, MIC);
            }
            else if (A.IsA('CMMSkeletalTestActor'))
            {
                CMMSkeletalTestActor(A).SkeletalMeshComponent.SetMaterial(0, MIC);
            }
        }
    }
    // romutate spawn2
    if (Locs(Args[0]) == "spawn2")
    {
        SpawnTestActor(Sender, "nodynamicmaterial");
    }

    super.ROMutate(MutateString, Sender, ResultMsg);
}

simulated function SpawnTestActor(PlayerController Player, string Type, optional MaterialInstanceConstant MaterialToApply)
{
    local Actor SpawnedActor;
    local vector Loc;

    Loc = Player.Pawn.Location + (Normal(vector(Player.Pawn.Rotation)) * 100);
    `cmmlog("spawning test actor at " $ Loc);
    if (MaterialToApply != None)
    {
        Player.ClientMessage("[HeloCombatMutator]: spawning test actor at: " $ Loc $ " with material: " $ MaterialToApply);
    }

    if (Type == "static")
    {
        SpawnedActor = Spawn(class'CMMStaticTestActor', Self,, Loc, Player.Pawn.Rotation);
        CMMStaticTestActor(SpawnedActor).StaticMeshComponent.SetMaterial(0, MaterialToApply);
    }
    else if (Type == "skeletal")
    {
        SpawnedActor = Spawn(class'CMMSkeletalTestActor', Self,, Loc, Player.Pawn.Rotation);
        CMMSkeletalTestActor(SpawnedActor).SkeletalMeshComponent.SetMaterial(0, MaterialToApply);
    }
    else if (Type == "nodynamicmaterial")
    {
        SpawnedActor = Spawn(class'CMMSkeletalTestActor2', Self,, Loc, Player.Pawn.Rotation);
    }
    else
    {
        `cmmlog("invalid type: " $ Type);
    }

    if (SpawnedActor != None)
    {
        TestActors.AddItem(SpawnedActor);
    }
}

DefaultProperties
{
    LevelsToPreload(0)="VNTE-MaterialContainer2"
}
