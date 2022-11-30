UI::Font@ font16 = UI::LoadFont("DroidSans.ttf", 16);
UI::Font@ font18 = UI::LoadFont("DroidSans.ttf", 18);
UI::Font@ font20 = UI::LoadFont("DroidSans.ttf", 20);

[Setting hidden]
bool Setting_Enabled = true;

bool PluginIsEnabled() {
    return Setting_Enabled;
}

[Setting hidden]
bool State_FirstRunComplete = false;

[Setting hidden]
bool State_CheckedForV1Skins = false;

[Setting hidden]
bool State_SetUpAuxSkins = false;

[Setting hidden]
bool Setting_SetUpModelsV2 = false;

/* choice of model */

enum ChoiceOfModel {
    MaleDarkGray,
    FemaleDarkGray,
    MaleCreamyGold,
    FemaleCreamyGold,
    MaleGold,
    MalePink,
    MaleRed,
    MaleGreen,
    MaleBlue
}

string[] ChoiceOfModelStr =
    { "Male - Dark Gray (Default)"
    , "Female - Dark Gray"
    , "Male - Creamy Gold"
    , "Female - Creamy Gold"
    , "Male - Gold"
    , "Male - Pink"
    , "Male - Red"
    , "Male - Green"
    , "Male - Blue"
    };

[Setting hidden]
ChoiceOfModel Setting_CurrentModel = ChoiceOfModel::MaleDarkGray;

/* settings rendering */

[SettingsTab name="0. Skins" icon="Users"]
void RenderMenuBgSettings() {
    if (UI::Button("Open Skins Folder in Explorer")) {
        OpenExplorerPath(IO::FromUserGameFolder("Skins\\Models\\HelmetPilot"));
    }

    bool newEnabled = UI::Checkbox("Plugin Enabled?", Setting_Enabled);
    if (newEnabled && !Setting_Enabled) startnew(OnSettingsChanged);  // we need to manually check for updated settings
    Setting_Enabled = newEnabled;
    AddSimpleTooltip("This plugin only does something when you change a setting,\n so this checkbox is only useful in that, when you uncheck the box,\n whatever model is selected will be applied. \n(A game restart is still required.)");

    if (!PluginIsEnabled()) UI::BeginDisabled();

    UI::Text("Player Model Choice:");
    if (UI::BeginCombo("##player-model-choice", ChoiceOfModelStr[Setting_CurrentModel])) {
        for (uint i = 0; i < ChoiceOfModelStr.Length; i++) {
            if (UI::Selectable(ChoiceOfModelStr[i], int(i) == Setting_CurrentModel)) {
                Setting_CurrentModel = ChoiceOfModel(i);
                startnew(OnSettingsChanged);
            }
        }
        UI::EndCombo();
    }

    DrawModelTable();

    VPad();
    UI::Dummy(vec2(25, 0));
    UI::SameLine();
    if (UI::Button("Update Default Skin")) {
        startnew(OnSettingsChanged);
    }

    if (currWaiting) {
        UI::Dummy(vec2(15, 0));
        UI::Text("\\$<\\$cf3Note: a skin refresh is pending.\\$>\nPlease navigate to the 'Solo', 'Live', or 'Local' main menu page to reload skins.");
        UI::Text("Current Menu Page: " + GetCurrentMenuPage());
    }

    UI::Dummy(vec2(1, 25));
    SubHeading("Aux Skins");
    UI::Dummy(vec2(25, 0));
    UI::SameLine();
    if (UI::Button("Re-Initialize Aux Skins")) {
        startnew(PopulateAuxSkins);
    }

    UI::Dummy(vec2(1, 25));
    SubHeading("Wizard");
    UI::Dummy(vec2(25, 0));
    UI::SameLine();
    if (UI::Button("Show me the wizard again!")) {
        Wizard::currWizardSlide = 0;
        State_WizardShouldRun_22_09_14 = true;
        Wizard::ShowWindow = true;
    }

    if (!PluginIsEnabled()) UI::EndDisabled();
}

/* model selection incl textures */

UI::Texture@ maledarkgray = UI::LoadTexture("img/male-dark-gray.png");
UI::Texture@ femaledarkgray = UI::LoadTexture("img/female-dark-gray.png");
UI::Texture@ malecreamygold = UI::LoadTexture("img/male-creamy-gold.png");
UI::Texture@ femalecreamygold = UI::LoadTexture("img/female-creamy-gold.png");
UI::Texture@ bmx22cGold = UI::LoadTexture("img/bmx22c_MaleGold.png");
UI::Texture@ bmx22cRed = UI::LoadTexture("img/bmx22c_MaleRed.png");
UI::Texture@ bmx22cPink = UI::LoadTexture("img/bmx22c_MalePink.png");
UI::Texture@ bmx22cGreen = UI::LoadTexture("img/bmx22c_MaleGreen.png");
UI::Texture@ bmx22cBlue = UI::LoadTexture("img/bmx22c_MaleBlue.png");

UI::Texture@[] bmx22cTexs = {bmx22cGold, bmx22cPink, bmx22cRed, bmx22cGreen, bmx22cBlue};

bool DrawModelOption(UI::Texture@ tex, const string &in name, bool selected, bool inTable = true) {
    if (inTable) UI::TableNextColumn();
    if (tex is null) return false;
    float ImgWidth = UI::GetContentRegionAvail().x;
    auto ratio = tex.GetSize().x / tex.GetSize().y;
    UI::Image(tex, vec2(ImgWidth, ImgWidth / ratio));
    bool ret = UI::IsItemClicked();
    ret = UI::RadioButton(name, selected) || ret;
    return ret;
}

void DrawModelTable(uint nCols = 4) {
    auto preModel = Setting_CurrentModel;
    UI::PushFont(font18);

    if (UI::BeginTable("pac-skin-table", nCols, TableFlagsStretchSame())) {
        // 1,1
        if (DrawModelOption(maledarkgray, "Male, Dark Gray Suit (Default)", Setting_CurrentModel == ChoiceOfModel::MaleDarkGray))
            Setting_CurrentModel = ChoiceOfModel::MaleDarkGray;
        // 1,2
        if (DrawModelOption(femaledarkgray, "Female, Dark Gray Suit", Setting_CurrentModel == ChoiceOfModel::FemaleDarkGray))
            Setting_CurrentModel = ChoiceOfModel::FemaleDarkGray;
        // 2,1
        if (DrawModelOption(malecreamygold, "Male, Creamy Gold Suit", Setting_CurrentModel == ChoiceOfModel::MaleCreamyGold))
            Setting_CurrentModel = ChoiceOfModel::MaleCreamyGold;
        // 2,2
        if (DrawModelOption(femalecreamygold, "Female, Creamy Gold Suit", Setting_CurrentModel == ChoiceOfModel::FemaleCreamyGold))
            Setting_CurrentModel = ChoiceOfModel::FemaleCreamyGold;
        UI::EndTable();
    }

    if (UI::BeginTable("pac-skin-table-bmx", 5, TableFlagsStretchSame())) {
        for (uint i = 0; i < 5; i++) {
            if (DrawModelOption(bmx22cTexs[i], ChoiceOfModelStr[i + 4], Setting_CurrentModel == ChoiceOfModel(4 + i)))
                Setting_CurrentModel = ChoiceOfModel(4 + i);
        }
        UI::EndTable();
    }

    UI::PopFont();
    if (preModel != Setting_CurrentModel)
        startnew(OnSettingsChanged);
}
