
[Setting hidden]
bool State_WizardShouldRun_22_09_14 = true;

[Setting hidden]
bool Consent_ChangeDefault = false;

[Setting hidden]
bool Consent_AuxSkins = false;

[SettingsTab name="1. Consent"]
void RenderConsentSettings() {
    Consent_ChangeDefault = UI::Checkbox("Manage Default Skin", Consent_ChangeDefault);
    AddSimpleTooltip("Management (including deletion) of the default character skin (HelmetPilot\\Stadium).\nGame restart required on change.");
    Consent_AuxSkins = UI::Checkbox("Manage Auxilary Skins (combinations)", Consent_AuxSkins);
    AddSimpleTooltip("Management (including deletion) of several auxillary skins (color/gender combos).\nGame restart required on change.");
}


bool GetLatestWizardShouldRun() {
    return State_WizardShouldRun_22_09_14;
}

void SetLatestWizardShouldRun(bool v) {
    State_WizardShouldRun_22_09_14 = v;
}

namespace Wizard {
    UI::Font@ font = font20;

    int currWizardSlide = 0;
    // const int2 WindowSize = int2(900, 600);
    // float ImgWidth = (float(WindowSize.x) - 50)/4;
    float ImgCols = 2;
    bool hasReboundOnce = false;
#if DEV
    string buildId = "aps (dev)";
#else
    string buildId = "aps";
#endif
    string uiId = buildId + "-wiz";

    float get_ImgWidth() {
        return UI::GetContentRegionAvail().x;
    }

    int2 get_FullScreenSize() {
        return int2(Draw::GetWidth(), Draw::GetHeight());
    }

    int2 get_WindowSize() {
        return Vec2ToInt2(Int2ToVec2(FullScreenSize) * vec2(.75, .8));
    }

    void Render() {
        if (GetLatestWizardShouldRun()) {
            RenderWizardUI();
        }
    }

    bool ShowWindow = true;

    void RenderWizardUI() {
        if (!ShowWindow)
            return;
        UI::PushFont(font);
        int2 pos = (FullScreenSize - WindowSize) / 2;
        UI::SetNextWindowPos(pos.x, pos.y, UI::Cond::FirstUseEver);
        UI::SetNextWindowSize(WindowSize.x, WindowSize.y, UI::Cond::FirstUseEver);
        if (UI::Begin("Setup Wizard: Alt Player Model/Skin##" + uiId, ShowWindow, GetWinFlags())) {
            UI::Dummy(vec2(150, 20));
            RenderSlide(currWizardSlide);
            UI::End();
        }
        UI::PopFont();
    }

    int GetWinFlags() {
        return 0
            // | UI::WindowFlags::NoResize
            | UI::WindowFlags::NoCollapse
            | UI::WindowFlags::NoDocking
            // | UI::WindowFlags::NoTitleBar
            ;
    }

    void RenderSlide(int slideIx) {
        switch (slideIx) {
            case 0: RenderOpeningSlide(); break;
            case 1: RenderConsentSlide(); break;
            case 2: RenderDoneSlide(); break;
            default: UI::Text("unknown slide: " + slideIx);
        }
    }

    void VPad() {
        UI::Dummy(vec2(2, 10));
    }
    void Sep() {
        VPad();
        UI::Separator();
        VPad();
    }

    void RenderOpeningSlide() {
        DrawCenteredInTable(uiId + "-welcome", function() {
            UI::Text("Welcome to the Alt Player Skin wizard");
        });
        UI::TextWrapped("Please choose your default skin (or just click next):");
        Sep();
        DrawModelTable();
        DrawCenteredInTable(uiId + "-to-slide-2", function() {
            if (UI::Button(Icons::AngleDoubleRight + " Next " + Icons::AngleDoubleLeft)) {
                Wizard::currWizardSlide++;
            }
        });
    }

    bool setTmpConsentVars = false;
    bool tmpConsentDefault = Consent_ChangeDefault;
    bool tmpConsentAux = Consent_AuxSkins;

    bool ConsentRadios(const string &in id, bool checked) {
        VPad();
        UI::Dummy(vec2(25, 0));
        UI::SameLine();
        UI::BeginGroup();
        bool ret = checked;
        if (UI::RadioButton("I do not consent##" + id, !checked))
            ret = false;
        if (UI::RadioButton("I consent##" + id, checked))
            ret = true;
        UI::EndGroup();
        return ret;
    }

    void RenderConsentSlide() {
        if (!setTmpConsentVars) {
            tmpConsentDefault = Consent_ChangeDefault;
            tmpConsentAux = Consent_AuxSkins;
            setTmpConsentVars = true;
        }

        DrawCenteredInTable(uiId + "-aps-consent", function() {
                UI::Text("Consent Request");
        });
        VPad();
        UI::TextWrapped("This plugin works by managing files in \\$b8fDocuments\\Trackmania\\Skins\\Models\\$z. For full functionality, please consent to the following:");
        Sep();
        Heading("Manage Default Skin");
        UI::TextWrapped("Management (including deletion) of the default skin in \\$b8fD\\T\\Skins\\Models\\HelmetPilot\\Stadium\\$z. When the default skin is applied, this directory is deleted.");
        tmpConsentDefault = ConsentRadios("mng-default", tmpConsentDefault);
        Sep();
        Heading("Manage Auxillary Skins");
        UI::TextWrapped("Management (including deletion) of the several other skins in \\$b8fD\\T\\Skins\\Models\\HelmetPilot\\$z. (The ones on the prior page.)");
        UI::Markdown("This is required to enable some features of the [Menu Background Scene Randomizer](https://openplanet.dev/plugin/menu-bg-scene-randomizer).");
        tmpConsentAux = ConsentRadios("mng-aux", tmpConsentAux);
        Sep();
        UI::Text("This plugin will" + (tmpConsentDefault ? "" : " \\$fa7not\\$z") + " manage the default skin.");
        UI::Text("This plugin will" + (tmpConsentAux ? "" : " \\$fa7not\\$z") + " manage the auxillary skins skin.");
        VPad();
        UI::TextWrapped("Note: you can change this in settings later, but the relevant features won't be enabled unless you agree to the above.");
        VPad();
        DrawCenteredInTable(uiId + "-to-slide-3", function() {
            RenderBackButton();
            if (UI::Button("Continue")) {
                Consent_ChangeDefault = tmpConsentDefault;
                Consent_AuxSkins = tmpConsentAux;
                Wizard::currWizardSlide++;
            }
        });
    }

    void RenderBackButton() {
        if (Wizard::currWizardSlide == 0) return;
        if (UI::Button("Go Back")) {
            Wizard::currWizardSlide--;
        }
        UI::SameLine();
        UI::Dummy(vec2(20, 0));
        UI::SameLine();
    }

    void RenderDoneSlide() {
        UI::Dummy(vec2(0, 100));
        DrawCenteredInTable(uiId + "-ur-done", function() {
            UI::Text("\\$5e8You're done! Gz.");
        });
        VPad();
        UI::TextWrapped("Skins are being configured now. You should see a notification when that process is complete.");
        UI::TextWrapped("Please restart the game for the new skins to load.");
        VPad();
        UI::TextWrapped("Feedback, suggestions, and requests welcome: @XertroV on the Openplanet discord.");
        VPad();
        DrawCenteredInTable(uiId + "-finish-btn", function() {
            RenderBackButton();
            if (UI::Button("Close Wizard")) {
                SetLatestWizardShouldRun(false);
            }
        });
    }
}
