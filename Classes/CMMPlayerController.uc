class CMMPlayerController extends ROPlayerController;

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
            `cmmlog("Levels[" $ Idx $ "]: " $ GetCMM().LevelsToPreload[Idx]);
            if (GetCMM().LevelsToPreload[Idx] != '')
            {
                LevelsArr.AddItem(GetCMM().LevelsToPreload[Idx]);
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
