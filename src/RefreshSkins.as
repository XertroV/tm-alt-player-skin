string GetCurrentMenuPage() {
    try {
        auto mc = cast<CGameManiaPlanet>(GetApp()).MenuManager.MenuCustom_CurrentManiaApp;
        if (mc is null) return "";
        auto ls = mc.UILayers;
        bool foundOverlay = false;
        CGameUILayer@ pageLayer;
        // Overlay_MenuBackground at ix=13, so start a little before
        for (uint i = 11; i < ls.Length; i++) {
            auto layer = ls[i];
            if (!foundOverlay) {
                if (layer.ManialinkPageUtf8.StartsWith("\n<manialink name=\"Overlay_MenuBackground\"")) {
                    foundOverlay = true;
                }
                continue;
            } else if (layer.IsVisible) {
                if (layer.ManialinkPageUtf8.StartsWith("\n<manialink name=\"Page_")) {
                    @pageLayer = layer;
                    break;
                }
            }
        }
        if (pageLayer is null) return "";
        return pageLayer.ManialinkPageUtf8.SubStr(23, 100).Split('"', 2)[0];
    } catch {
        warn("Got error getting curr menu page: " + getExceptionInfo());
    }
    return "";
}

const string[] menuPagesRefreshOn = {"Solo", "Live", "Local"};

bool currWaiting = false;
void WaitToRefreshSkins() {
    // don't run 2x copies at once
    if (currWaiting) return;
    currWaiting = true;
    while (menuPagesRefreshOn.Find(GetCurrentMenuPage()) < 0) {
        yield();
    }
    currWaiting = false;
    cast<CGameManiaPlanet>(GetApp()).MenuManager.MenuCustom_CurrentManiaApp.DataFileMgr.Media_RefreshFromDisk(CGameDataFileManagerScript::EMediaType::Skins, 4);
    UI::ShowNotification(Meta::ExecutingPlugin().Name, "Skins Refreshed!\nTry entering a map. Your skin should have updated.", vec4(.1, .5, .2, .8), 10000);
}
