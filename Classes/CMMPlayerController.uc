class CMMPlayerController extends ROPlayerController;

simulated function CustomMaterialMutator GetCMM()
{
    return CustomMaterialMutator(WorldInfo.Game.BaseMutator);
}

reliable client function ClientPreloadCustomMaterials()
{
    `cmmlog("PreloadCustomMaterials starting on " $ self);
    GetCMM().PreloadCustomMaterials();
    `cmmlog("PreloadCustomMaterials done on " $ self);
}

reliable client function ClientPreloadLevels()
{
    `cmmlog("PreLoadLevels starting on " $ self);
    GetCMM().PreLoadLevels();
    `cmmlog("PreLoadLevels done on " $ self);
}
