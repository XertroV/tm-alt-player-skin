// 0th bit: male/female; 1st bit: black/white
enum ModelPreset
    { FemaleDG = 0
    , MaleDG = 1
    , FemaleCG = 2
    , MaleCG = 3
    , MaleGold = 5
    , MalePink = 7
    , MaleRed = 9
    , MaleGreen = 11
    , MaleBlue = 13
    }

string GetBmxColor(ModelPreset mp) {
    if (mp == 5) return "Gold";
    if (mp == 7) return "Pink";
    if (mp == 9) return "Red";
    if (mp == 11) return "Green";
    if (mp == 13) return "Blue";
    return "ERR_NO_COLOR";
}

const string OutputDir = IO::FromUserGameFolder("Skins\\Models\\HelmetPilot\\");
const string PrimaryInGameSkinDir = IO::FromUserGameFolder("Skins\\Models\\HelmetPilot\\Stadium");
const string StorageDir = IO::FromStorageFolder("\\");
const string ExtractBase = IO::FromDataFolder("Extract\\");

const string MaleCGHelmetUrl = "https://s3.us-east-1.wasabisys.com/xert/TM/MaleCG_Helmet_B.dds";
const string MaleCGBodyUrl = "https://s3.us-east-1.wasabisys.com/xert/TM/MaleCG_Body_B.dds";
const string FemaleDGBodyUrl = "https://s3.us-east-1.wasabisys.com/xert/TM/FemaleDG_Body_B.dds";

string SkinBaseUrl(const string &in filename) {
    return "https://s3.us-east-1.wasabisys.com/xert/TM/" + filename;
}

string[] SkinBaseUrlPair(const string &in filename) {
    return {SkinBaseUrl(filename), filename};
}

const string[] SourceFolders = { "GameData/Skins/Models/CharacterPilot/", "GameData/Skins/Models/HelmetPilot/" };

string PathToSourceZipOrFolder(const string &in srcName) {
    if (srcName == "Stadium")
        return SourceFolders[1] + srcName;
    if (srcName.StartsWith('Stadium'))
        return SourceFolders[0] + srcName;
    throw('unknown source named: ' + srcName);
    return "";
}

string[][] CustomTextures =
    { { MaleCGHelmetUrl, "MaleCG_Helmet_B.dds" }
    , { MaleCGBodyUrl, "MaleCG_Body_B.dds" }
    , { FemaleDGBodyUrl, "FemaleDG_Body_B.dds" }
    };

bool loadedBmx = false;
void AddBmxSkins() {
    if (loadedBmx) return;
    loadedBmx = true;
    string[] colors = {"Gold", "Pink", "Red", "Green", "Blue"};
    string[] parts = {"Body", "Helmet", "HelmetVisor", "ChestVisor"};
    for (uint c = 0; c < colors.Length; c++) {
        auto color = colors[c];
        for (uint p = 0; p < parts.Length; p++) {
            CustomTextures.InsertLast(SkinBaseUrlPair("Male_" + color + "_" + parts[p] + "_B.dds"));
        }
    }
}

dictionary CustTexIdMap =
    { {"MaleCG_Body", CustomTextures[1][1] }
    , {"FemaleDG_Body", CustomTextures[2][1] }
    , {"MaleCG_Helmet", CustomTextures[0][1] }
    };

void EnsureCustomTexturesDownloaded() {
    for (uint i = 0; i < CustomTextures.Length; i++) {
        string url = CustomTextures[i][0];
        string fname = CustomTextures[i][1];
        startnew(CheckCustomTextureAndDLWhenAbsent, CustomTexture(url, fname));
    }
}

void AwaitCustomTextures() {
    startnew(EnsureCustomTexturesDownloaded);
    bool gotAllTextures = false;
    while (!gotAllTextures) {
        yield();
        gotAllTextures = true;
        for (uint i = 0; i < CustomTextures.Length; i++) {
            auto fname = CustomTextures[i][1];
            gotAllTextures = gotAllTextures && IO::FileExists(IO::FromStorageFolder(fname));
        }
    }
}

class CustomTexture {
    string url; string filename;
    CustomTexture(const string &in u, const string &in f) {
        url = u; filename = f;
    }
}

void CheckCustomTextureAndDLWhenAbsent(ref@ r) {
    auto ct = cast<CustomTexture>(r);
    if (ct is null) {
        throw("Got null CT in CheckCustomTextureAndDLWhenAbsent");
    }
    auto dest = IO::FromStorageFolder(ct.filename);
    if (IO::FileExists(dest)) return;
    warn("Downloading: " + ct.url);
    auto req = Net::HttpRequest();
    req.Url = ct.url;
    req.Start();
    while(!req.Finished()) { yield(); }
    if (req.ResponseCode() != 200) {
        warn("Downloading " + ct.url + " and got response code: " + req.ResponseCode());
        return;
    }
    req.SaveToFile(dest);
    print("Downloaded " + ct.url);
}

const string[] _BodyFiles = {"Body_B.dds", "Body_E.dds", "Body_N.dds", "Body_R.dds"};
const string[] _CVFiles = {"ChestVisor_B.dds", "ChestVisor_E.dds", "ChestVisor_N.dds", "ChestVisor_R.dds"};
const string[] _HelmetFiles = {"Helmet_B.dds", "Helmet_E.dds", "Helmet_N.dds", "Helmet_R.dds"};
const string[] _HVFiles = {"HelmetVisor_B.dds", "HelmetVisor_N.dds", "HelmetVisor_R.dds"};
const string _MeshFile = "Player.Mesh.gbx";
const string _AnimFile = "Player.Anim.Gbx";
const string _IconFile = "Icon.tga";

class ModelSpec {
    string[] m_bodySrc;
    string[] m_cvSrc;
    string[] m_helmetSrc;
    string[] m_hvSrc;
    string m_meshSrc;
    string m_animSrc;
    string m_iconSrc;
    string m_zipSrc;

    ModelSpec(ModelPreset mp) {
        bool stdSkins = uint(mp) <= 3;
        bool isBmxSkin = uint(mp) >= 4 && uint(mp) <= 13;
        bool male = uint(mp) & 1 == 1;
        bool white = stdSkins && mp & 2 == 2;

        m_bodySrc.InsertLast(male ? "StadiumMale" : "StadiumFemale");
        if (stdSkins && (!male ^^ white))
            m_bodySrc.InsertLast(mp == ModelPreset::MaleCG ? "MaleCG_Body" : "FemaleDG_Body");
        // ,"FemaleDG_Body"}) : (!male ? "StadiumFemale" : "StadiumMale|MaleCG_Body");
        m_cvSrc.InsertLast((isBmxSkin || !white) ? "StadiumMale" : "StadiumFemale");
        // m_helmetSrc = (male && white) ? "MaleCG_Helmet" : "Stadium";
        m_helmetSrc.InsertLast("Stadium");
        if (stdSkins && male && white) m_helmetSrc.InsertLast("MaleCG_Helmet");
        m_hvSrc.InsertLast((isBmxSkin || !white) ? "Stadium" : "StadiumFemale");
        m_meshSrc = male ? "StadiumMale" : "StadiumFemale";
        m_animSrc = "StadiumMale";
        m_iconSrc = "StadiumMale";
        m_zipSrc = "StadiumMale";
        if (isBmxSkin) {
            // m_bodySrc.InsertLast(BmxBodySrc(mp));
            auto color = GetBmxColor(mp);
            m_bodySrc.InsertLast("Male_" + color + "_Body_B.dds");
            m_helmetSrc.InsertLast("Male_" + color + "_Helmet_B.dds");
            m_hvSrc.InsertLast("Male_" + color + "_HelmetVisor_B.dds");
            m_cvSrc.InsertLast("Male_" + color + "_ChestVisor_B.dds");
        }
    }

    void WriteModelSpecTo(const string &in SkinName) {
        string SkinPath = OutputDir + SkinName;
        CleanDirectory(SkinPath);
        WriteZipFile(SkinPath);
        WriteBodyFiles(SkinPath);
        WriteCVFiles(SkinPath);
        WriteHVFiles(SkinPath);
        WriteMeshFile(SkinPath);
        WriteAnimFile(SkinPath);
        WriteIconFile(SkinPath);
        WriteHelmetFiles(SkinPath);
        UI::ShowNotification(Meta::ExecutingPlugin().Name, "Skin Installed: " + SkinName, vec4(.1, .5, .2, .8), 5000);
    }

    // prepare directory to ensure there's no prior files
    private void CleanDirectory(const string &in folder) {
        if (!IO::FolderExists(folder))
            IO::CreateFolder(folder, true);
        auto existingFiles = IO::IndexFolder(folder, true);
        for (uint i = 0; i < existingFiles.Length; i++) {
            auto exF = existingFiles[i];
            auto exFL = exF.ToLower();
            if (exFL.EndsWith('.dds') || exFL.EndsWith('.tga') || exFL.EndsWith('.gbx')) {
                trace('Removing prior file: ' + exF);
                IO::Delete(exF);
            }
        }
    }

    private CSystemFidFile@ GetGameFidFile(const string &in src) {
        auto fid = cast<CSystemFidFile>(Fids::GetGame(src));
        if (fid is null) throw('Could not find an Fid we know to exist: ' + src);
        return fid;
    }

    private void RunExtract(CSystemFidFile@ fid, const string &in src, const string &in dest) {
        // bool extractAfter = IO::FileExists(ExtractBase + src);
        fid.Extract();
        CopyFile(ExtractBase + src, dest);
        // if (extractAfter) fid.Extract();
    }

    private void CopyFile(const string &in src, const string &in dest) {
        if (src.Length == 0) throw('CopyLocalFile got empty string as src');
        print('Copying file \'' + src + "' to '" + dest + "'");
        IO::File srcF(src, IO::FileMode::Read);
        IO::File destF(dest, IO::FileMode::Write);
        destF.Write(srcF.Read(srcF.Size()));
    }

    private void CopyLocalFile(const string &in localSrc, const string &in dest) {
        if (localSrc.Length == 0) throw('CopyLocalFile got empty string as localSrc');
        print('Copying file \'' + localSrc + "' to '" + dest + "'");
        auto src = IO::FromStorageFolder(localSrc);
        IO::File srcF(src, IO::FileMode::Read);
        IO::File destF(dest, IO::FileMode::Write);
        destF.Write(srcF.Read(srcF.Size()));
    }

    private void WriteZipFile(const string &in sp) {
        string zipDest = sp + ".zip";
        string zipSrc = PathToSourceZipOrFolder(m_zipSrc) + ".zip";
        auto fid = GetGameFidFile(zipSrc);
        RunExtract(fid, zipSrc, zipDest);
    }

    private void WriteElementFiles(const string &in elName, const string[] srcFiles, const string[] Files, const string &in SkinPath) {
        WriteFiles(srcFiles[0], Files, SkinPath);
        if (srcFiles.Length <= 1) return;
        string extraTex = srcFiles[1];
        if (!extraTex.EndsWith(".dds")) {
            print('extra tex: ' + extraTex);
            extraTex = string(CustTexIdMap[srcFiles[1]]);
            print('extra tex: ' + extraTex);
        }
        CopyLocalFile(extraTex, SkinPath + "\\" + elName + "_B.dds");
    }

    private void WriteBodyFiles(const string &in SkinPath) {
        WriteElementFiles("Body", m_bodySrc, _BodyFiles, SkinPath);
        // WriteFiles(m_bodySrc[0], _BodyFiles, SkinPath);
        // if (m_bodySrc.Length <= 1) return;
        // CopyLocalFile(string(CustTexIdMap[m_bodySrc[1]]), SkinPath + "\\Body_B.dds");
    }

    private void WriteCVFiles(const string &in SkinPath) {
        WriteElementFiles("ChestVisor", m_cvSrc, _CVFiles, SkinPath);
        // WriteFiles(m_cvSrc, _CVFiles, SkinPath);
    }

    private void WriteHelmetFiles(const string &in SkinPath) {
        WriteElementFiles("Helmet", m_helmetSrc, _HelmetFiles, SkinPath);
        // WriteFiles("Stadium", _HelmetFiles, SkinPath);
        // if (m_helmetSrc == "MaleCG_Helmet") {
        //     CopyLocalFile("MaleCG_Helmet_B.dds", SkinPath + "\\Helmet_B.dds");
        // }
    }

    private void WriteHVFiles(const string &in SkinPath) {
        WriteElementFiles("HelmetVisor", m_hvSrc, _HVFiles, SkinPath);
        // WriteFiles(m_hvSrc, _HVFiles, SkinPath);
    }

    private void WriteMeshFile(const string &in SkinPath) {
        WriteFile(m_meshSrc, _MeshFile, SkinPath);
    }

    private void WriteAnimFile(const string &in SkinPath) {
        WriteFile(m_animSrc, _AnimFile, SkinPath);
    }

    private void WriteIconFile(const string &in SkinPath) {
        WriteFile(m_iconSrc, _IconFile, SkinPath);
    }

    private void WriteFile(const string &in fSrc, const string &in fName, const string &in SkinPath) {
        string dest = SkinPath + "\\" + fName;
        string src = PathToSourceZipOrFolder(fSrc) + "\\" + fName;
        auto fid = GetGameFidFile(src);
        RunExtract(fid, src, dest);
    }

    private void WriteFiles(const string &in fSrc, const string[] &in fNames, const string &in SkinPath) {
        for (uint i = 0; i < fNames.Length; i++) {
            WriteFile(fSrc, fNames[i], SkinPath);
        }
    }
}

void RemoveCustomPrimarySkin() {
    if (!Consent_ChangeDefault) return;
    auto skinDir = PrimaryInGameSkinDir;
    if (IO::FolderExists(skinDir)) {
        warn("Removing custom skin folder for player character: " + skinDir);
        IO::DeleteFolder(skinDir, true);
    }
    auto zipFile = skinDir + ".zip";
    if (IO::FileExists(zipFile)) {
        warn("Removing custom skin zip file for player character: " + zipFile);
        IO::Delete(zipFile);
    }
}
