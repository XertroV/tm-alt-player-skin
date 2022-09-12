/* overview:

  the plugin will add files to `Trackmania\Skins\Models\CharacterPilot\StadiumMale`
  to change the default skin that's used.

  other skins could be support too if ppl make them, but IDK how.

  on install or change of settings:
  - extract skin and add to folder
  - notify user that it's done and to restart the game.

  settings: male or female
  */

void Main() {
    // we do stuff through coros so settings have a chance to load
    startnew(CoroMain);
}

void OnSettingsChanged() {
    UpdatePlayerSkin();
}

void CoroMain() {
    sleep(100);  // wait for settings etc
    if (Setting_FirstRunDone == false) {
        UpdatePlayerSkin();
    }
}


bool GameFileExists(const string &in path) {
    return Fids::GetGame(path).ByteSize > 0;
}


enum ChoiceOfModel {
    StadiumMale,
    StadiumFemale
}

string[] ChoiceOfModelStr = {"StadiumMale", "StadiumFemale"};

// use Fids::GetGameFolder
string[][] ModelFolders =
    { { "GameData/Skins/Models/CharacterPilot/StadiumMale", "GameData/Skins/Models/HelmetPilot/Stadium" }
    , { "GameData/Skins/Models/CharacterPilot/StadiumFemale" }
};

// we need to set both, I think
string[] destinationFolders =
    { IO::FromUserGameFolder("Skins\\Models\\CharacterPilot\\StadiumMale")
    , IO::FromUserGameFolder("Skins\\Models\\HelmetPilot\\Stadium")
    };

string opExtractBase = IO::FromDataFolder("Extract");

void UpdatePlayerSkin() {
    // auto skinFolder = 'GameData/Skins/Models/CharacterPilot/StadiumFemale';
    auto skinFolders = ModelFolders[Setting_CurrentModel];

    for (uint df = 0; df < destinationFolders.Length; df++) {
        auto destinationFolder = destinationFolders[df];
        print('Copying skin to destination folder: ' + destinationFolder);
        if (!IO::FolderExists(destinationFolder))
            IO::CreateFolder(destinationFolder, true);
        auto existingFiles = IO::IndexFolder(destinationFolder, true);
        for (uint i = 0; i < existingFiles.Length; i++) {
            auto exF = existingFiles[i];
            auto exFL = exF.ToLower();
            if (exFL.EndsWith('.dds') || exFL.EndsWith('.tga') || exFL.EndsWith('.gbx')) {
                trace('Removing prior file: ' + exF);
                IO::Delete(exF);
            }
        }

        for (uint sf = 0; sf < skinFolders.Length; sf++) {
            auto skinFolder = skinFolders[sf];
            auto fid = cast<CSystemFidsFolder>(Fids::GetGameFolder(skinFolder));
            if (fid !is null) {
                // PrintLeaves(fid);
                for (uint i = 0; i < fid.Leaves.Length; i++) {
                    auto newF = fid.Leaves[i];
                    if (string(newF.FileName).ToLower() != "player.anim.gbx")  // we always use StadiumMale for this
                        ExtractAndCopySkin(skinFolder, newF, destinationFolder);
                }
            } else {
                auto msg = "Error: unable to open game folder at path: " + skinFolder;
                warn(msg);
                UI::ShowNotification("Alt Player Skin (Error)", msg, vec4(.9, .6, .0, .9));
            }
        }
    }

    // we need to use Player.Anim.Gbx from StadiumMale to get in-game animations (like steering) to work properly
    auto smFolder = ModelFolders[0][0];
    auto fid = cast<CSystemFidsFolder>(Fids::GetGameFolder(smFolder));
    for (uint df = 0; df < destinationFolders.Length; df++) {
        string dest = destinationFolders[df];
        for (uint i = 0; i < fid.Leaves.Length; i++) {
            auto newF = fid.Leaves[i];
            if (string(newF.FileName).ToLower() == "player.anim.gbx") {
                ExtractAndCopySkin(smFolder, newF, dest);
            }
        }
    }

    auto msg = "Success! Restart now required. \n \n Set skin to " + ChoiceOfModelStr[Setting_CurrentModel] + ". \n \n Please restart the game to see changes.";
    UI::ShowNotification("Alt Player Skin: " + ChoiceOfModelStr[Setting_CurrentModel], msg, vec4(.1, .5, .2, .4), 15000);
    Setting_FirstRunDone = true;
}

void ExtractAndCopySkin(const string &in base, CSystemFidFile@ fid, const string &in destinationFolder) {
    string src = opExtractBase + '\\' + base + '\\' + fid.FileName;
    string dest = destinationFolder + '\\' + fid.FileName;
    bool extractAfter = IO::FileExists(src);
    fid.Extract();
    IO::Move(src, dest);
    trace('Moved ' + src + ' to ' + dest);
    if (extractAfter) fid.Extract();
}

void PrintLeaves(CSystemFidsFolder@ f) {
    print('------------');
    print('contents of: ' + f.FullDirName);
    for (uint i = 0; i < f.Leaves.Length; i++) {
        print('- ' + f.Leaves[i].FileName);
    }
    print('------------');
}
