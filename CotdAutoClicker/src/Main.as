// c 2024-02-02
// m 2024-02-08

bool         queueJoin  = false;
bool         queueOk    = false;
bool         queueStay  = false;
bool         queueLeave = false;
const string title      = "\\$F88" + Icons::Forward + "\\$G COTD Auto-Clicker";

[Setting category="General" name="Enabled"]
bool S_Enabled = false;

[Setting category="General" name="Show window"]
bool S_Show = true;

[Setting category="General" name="Join as soon as possible after qualifier"]
bool S_AutoJoin = false;

[Setting category="General" name="Click OK at start of warmup"]
bool S_AutoOk = false;

enum AfterKO {
    Nothing,
    Leave,
    Stay
}

[Setting category="General" name="Action when knocked out"]
AfterKO afterKO = AfterKO::Nothing;

void Main() {
    while (true) {
        Loop();
        yield();
    }
}

// void RenderMenu() {
//     if (UI::BeginMenu(title)) {
//         if (UI::MenuItem("Auto-join", "", S_AutoJoin))
//             S_AutoJoin = !S_AutoJoin;

//         if (UI::MenuItem("Click 'OK'", "", S_AutoOk))
//             S_AutoOk = !S_AutoOk;

//         if (UI::MenuItem("Auto-leave after KO", "", S_AutoLeave))
//             S_AutoLeave = !S_AutoLeave;

//         if (UI::MenuItem("Auto-stay after KO", "", S_AutoStay))
//             S_AutoStay = !S_AutoStay;

//         UI::EndMenu();
//     }
// }

void Render() {
    if (!S_Show)
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);

    CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;
    if (CMAP is null)
        return;

    CTrackManiaNetworkServerInfo@ ServerInfo = cast<CTrackManiaNetworkServerInfo@>(Network.ServerInfo);
    if (ServerInfo is null)
        return;

    UI::Begin(title, S_Show, UI::WindowFlags::None);
        UI::BeginDisabled(queueJoin);
        if (UI::Button("Join"))
            queueJoin = true;
        UI::EndDisabled();

        UI::Separator();

        UI::BeginDisabled(queueOk);
        if (UI::Button("OK"))
            queueOk = true;
        UI::EndDisabled();

        UI::BeginDisabled(queueLeave);
        if (UI::Button("Leave"))
            queueLeave = true;
        UI::EndDisabled();

        UI::SameLine();
        UI::BeginDisabled(queueStay);
        if (UI::Button("Stay"))
            queueStay = true;
        UI::EndDisabled();
    UI::End();
}

void Loop() {
    if (!S_Enabled)
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);

    CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;
    if (CMAP is null)
        return;

    CTrackManiaNetworkServerInfo@ ServerInfo = cast<CTrackManiaNetworkServerInfo@>(Network.ServerInfo);
    if (ServerInfo is null)
        return;

    if (ServerInfo.CurGameModeStr == "TM_COTDQualifications_Online") {
        for (int i = CMAP.UILayers.Length - 1; i >= 0; i--) {
            CGameUILayer@ Layer = CMAP.UILayers[i];
            if (Layer is null || Layer.ManialinkPage.Length < 70)
                continue;

            if (string(Layer.ManialinkPage).SubStr(18, 50) == "UIModule_COTDQualifications_QualificationsProgress") {
                CGameManialinkFrame@ Button = cast<CGameManialinkFrame@>(Layer.LocalPage.GetFirstChild("button-join"));

                if (queueJoin) {
                    ClickButton(Button);
                    queueJoin = false;
                    yield();
                }

                return;
            }
        }
    } else if (ServerInfo.CurGameModeStr == "TM_KnockoutDailyOnline") {
        for (int i = CMAP.UILayers.Length - 1; i >= 0; i--) {
            CGameUILayer@ Layer = CMAP.UILayers[i];
            if (Layer is null || Layer.ManialinkPage.Length < 70)
                continue;

            string Page = string(Layer.ManialinkPage);

            if (Page.SubStr(18, 35) == "UIModule_KnockoutDaily_WelcomePopUp") {
                // CGameManialinkQuad@ Quad = cast<CGameManialinkQuad@>(Layer.LocalPage.GetFirstChild("ComponentTrackmania_Button_quad-background"));

                if (queueOk) {
                    queueOk = false;
                    ClickButton(Layer.LocalPage.GetFirstChild("ComponentTrackmania_Button_quad-background"));
                    yield();
                    return;
                }

            } else if (Page.SubStr(18, 32) == "UIModule_Knockout_KnockoutReward") {
                CGameManialinkFrame@ ElimWindow = cast<CGameManialinkFrame@>(Layer.LocalPage.GetFirstChild("frame-content"));
                if (ElimWindow is null || !ElimWindow.Visible)
                    continue;

                if (queueLeave) {
                    queueLeave = false;
                    ClickButton(Layer.LocalPage.GetFirstChild("button-quit"));
                    yield();
                    return;
                }

                if (queueStay) {
                    queueStay = false;
                    ClickButton(Layer.LocalPage.GetFirstChild("button-spectate"));
                    yield();
                    return;
                }
            }
        }
    }
}

void ClickButton(CGameManialinkControl@ Thing) {
    if (Thing is null) {
        warn("null Thing");
        return;
    }

    if (Thing.Control is null) {
        warn("null Control");
        return;
    }

    Thing.Control.OnAction();
}
