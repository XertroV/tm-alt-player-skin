/* overview:

  the plugin will add files to `Trackmania\Skins\Models\HelmetPilot\Stadium`
  to change the default skin that's used.

  other skins could be support too if ppl make them, but IDK how.

  on install or change of settings:
  - extract skin and add to folder
  - notify user that it's done and to restart the game.

  settings: male or female
  */

void Main() {
    AddBmxSkins();
    // we do stuff through coros so settings have a chance to load
    startnew(CoroMain);
    // startnew(TestMain);
}

void Render() {
   Wizard::Render();
}

void TestMain() {
    // auto ms = ModelSpec(ModelPreset::FemaleBlack);
    // ms.WriteModelSpecTo("Stadium");
}

void OnSettingsChanged() {
    UpdatePlayerSkin();
}

void CoroMain() {
    startnew(EnsureCustomTexturesDownloaded);
    sleep(100);  // wait for settings etc
    startnew(CoroMainDefaultSkin);
    startnew(CoroMainAuxSkin);
}

void CoroMainDefaultSkin() {
    while (!Consent_ChangeDefault) {
        sleep(100);
    }
    if (!State_FirstRunComplete) {
        UpdatePlayerSkin();
        State_FirstRunComplete = true;
    }
}
void CoroMainAuxSkin() {
    while (!Consent_AuxSkins) {
        sleep(100);
    }
    if (State_FirstRunComplete && !State_CheckedForV1Skins) startnew(RemoveOldSkins);
    if (!State_SetUpAuxSkins) {
        PopulateAuxSkins();
        State_SetUpAuxSkins = true;
    }
}

void RemoveOldSkins() {
    if (!Consent_AuxSkins) return;
    // run only if we've already run the plugin before and we haven't checked for old semi-broken skins
    if (!State_FirstRunComplete || State_CheckedForV1Skins) return;
    string oldDirBase = IO::FromUserGameFolder("Skins\\Models\\CharacterPilot\\");
    string[] oldSkinDirs = {"StadiumMale", "StadiumFemale"};
    for (uint i = 0; i < oldSkinDirs.Length; i++) {
        auto skinDir = oldDirBase + oldSkinDirs[i];
        if (IO::FolderExists(skinDir)) {
            warn("Removing old semi-broken skin folder: " + skinDir);
            IO::DeleteFolder(skinDir, true);
        }
        auto zipFile = skinDir + ".zip";
        if (IO::FileExists(zipFile)) {
            warn("Removing old semi-broken skin zip file: " + zipFile);
            IO::Delete(zipFile);
        }
    }
    State_CheckedForV1Skins = true;
}

void PopulateAuxSkins() {
    AwaitCustomTextures();
    UI::ShowNotification("Installing: Alt Player Skins", "Installing: StadiumFemaleDG, StadiumMaleDG, StadiumFemaleCG, StadiumMaleCG to Skins/Models/HelmetPilot/\n\n(Note: might get frame-y)", vec4(.5, .6, .2, .8), 5000);
    sleep(50);
    ModelSpec(ModelPreset::FemaleDG).WriteModelSpecTo("StadiumFemaleDG");
    sleep(50);
    ModelSpec(ModelPreset::MaleDG).WriteModelSpecTo("StadiumMaleDG");
    sleep(50);
    ModelSpec(ModelPreset::FemaleCG).WriteModelSpecTo("StadiumFemaleCG");
    sleep(50);
    ModelSpec(ModelPreset::MaleCG).WriteModelSpecTo("StadiumMaleCG");
    sleep(50);
    ModelSpec(ModelPreset::MaleGold).WriteModelSpecTo("bmx22c_MaleGold");
    sleep(50);
    ModelSpec(ModelPreset::MalePink).WriteModelSpecTo("bmx22c_MalePink");
    sleep(50);
    ModelSpec(ModelPreset::MaleRed).WriteModelSpecTo("bmx22c_MaleRed");
    sleep(50);
    ModelSpec(ModelPreset::MaleGreen).WriteModelSpecTo("bmx22c_MaleGreen");
    sleep(50);
    ModelSpec(ModelPreset::MaleBlue).WriteModelSpecTo("bmx22c_MaleBlue");
    UI::ShowNotification("Alt Player Skins Installed", "Added new skins to Skins/Models/HelmetPilot/", vec4(.1, .5, .2, .8), 10000);
}

void UpdatePlayerSkin() {
    if (!Consent_ChangeDefault) return;
    if (Setting_CurrentModel == ChoiceOfModel::MaleDarkGray) {
        RemoveCustomPrimarySkin();
    } else {
        AwaitCustomTextures();
        ModelPreset choice;
        if (uint(Setting_CurrentModel) < 4)  // std models
            choice = ModelPreset(Setting_CurrentModel ^ 1);  // flip last bit to swap to ModelPreset
        else if (uint(Setting_CurrentModel) <= 13) {  // bmx22c models
            choice = ModelPreset((uint(Setting_CurrentModel) - 4) * 2 + 5);
        }
        ModelSpec(choice).WriteModelSpecTo("Stadium");
    }
    auto msg = "Success! Refresh or game restart now required. \n \n Set skin to " + ChoiceOfModelStr[Setting_CurrentModel] + ". \n \n Navigate to 'Solo', 'Live', or 'Local' to refresh skins. (Changes should be visible after that.) If that does not work, please restart the game.";
    UI::ShowNotification("Alt Player Skin: " + ChoiceOfModelStr[Setting_CurrentModel], msg, vec4(.1, .5, .2, .4), 15000);
    startnew(WaitToRefreshSkins);
}
