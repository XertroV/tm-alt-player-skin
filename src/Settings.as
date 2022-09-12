[Setting hidden]
bool Setting_Enabled = true;

bool PluginIsEnabled() {
    return Setting_Enabled;
}

[Setting hidden]
bool Setting_FirstRunDone = false;

[Setting hidden]
ChoiceOfModel Setting_CurrentModel = ChoiceOfModel::StadiumFemale;

[SettingsTab name="General"]
void RenderMenuBgSettings() {
    bool newEnabled = UI::Checkbox("Plugin Enabled?", Setting_Enabled);
    if (newEnabled && !Setting_Enabled) OnSettingsChanged();  // we need to manually check for updated settings
    Setting_Enabled = newEnabled;
    AddSimpleTooltip("This plugin only does something when you change a setting,\n so this checkbox is only useful in that, when you uncheck the box,\n whatever model is selected will be applied. \n(A game restart is still required.)");

    if (!PluginIsEnabled()) UI::BeginDisabled();

    UI::Text("Player Model Choice:");
    if (UI::BeginCombo("##player-model-choice", ChoiceOfModelStr[Setting_CurrentModel])) {
        for (uint i = 0; i < ChoiceOfModelStr.Length; i++) {
            if (UI::Selectable(ChoiceOfModelStr[i], int(i) == Setting_CurrentModel)) {
                Setting_CurrentModel = ChoiceOfModel(i);
                OnSettingsChanged();
            }
        }
        UI::EndCombo();
    }

    if (!PluginIsEnabled()) UI::EndDisabled();
}
