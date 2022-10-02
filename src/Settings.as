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
    FemaleCreamyGold
}

string[] ChoiceOfModelStr = { "Male - Dark Gray (Default)", "Female - Dark Gray", "Male - Creamy Gold", "Female - Creamy Gold" };

[Setting hidden]
ChoiceOfModel Setting_CurrentModel = ChoiceOfModel::MaleDarkGray;

/* settings rendering */

[SettingsTab name="0. General"]
void RenderMenuBgSettings() {
    if (UI::Button("Open Skins Folder in Explorer")) {
        OpenExplorerPath(UI::FromUserGameFolder("Skins\\Models\\HelmetPilot"));
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

bool DrawModelOption(UI::Texture@ tex, const string &in name, bool selected, bool inTable = true) {
    if (inTable) UI::TableNextColumn();
    float ImgWidth = UI::GetContentRegionAvail().x;
    UI::Image(tex, vec2(ImgWidth, ImgWidth));
    bool ret = UI::IsItemClicked();
    ret = ret || UI::RadioButton(name, selected);
    return ret;
}

void DrawModelTable(uint nCols = 4) {
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
    UI::PopFont();
}
