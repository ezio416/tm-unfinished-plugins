// c 2024-03-08
// m 2024-03-08

uint[]       checkpoints;
const vec4   rowBgAltColor = vec4(0.0f, 0.0f, 0.0f, 0.5f);
const string title         = "\\$FFF" + Icons::SnapchatGhost + "\\$G Get Ghost";

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;

void Main() {
}

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void Render() {
    if (
        !S_Enabled
        || (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
    )
        return;

    UI::Begin(title, UI::WindowFlags::None);
        if (UI::Button("get ghost"))
            startnew(GetGhost);

        if (UI::BeginTable("##cp-table", 2, UI::TableFlags::RowBg | UI::TableFlags::ScrollY)) {
            UI::PushStyleColor(UI::Col::TableRowBgAlt, rowBgAltColor);

            UI::TableSetupScrollFreeze(0, 1);
            UI::TableSetupColumn("CP");
            UI::TableSetupColumn("time");
            UI::TableHeadersRow();

            for (uint i = 0; i < checkpoints.Length; i++) {
                UI::TableNextRow();

                UI::TableNextColumn(); UI::Text(tostring(i + 1));
                UI::TableNextColumn(); UI::Text(Time::Format(checkpoints[i]));
            }

            UI::PopStyleColor();
            UI::EndTable();
        }

    UI::End();
}

void GetGhost() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
    CGameManiaAppPlayground@ CMAP = Network.ClientManiaAppPlayground;

    if (
        App.RootMap is null
        || CMAP is null
        || CMAP.ScoreMgr is null
        || App.UserManagerScript is null
        || App.UserManagerScript.Users.Length == 0
    ) {
        checkpoints.RemoveRange(0, checkpoints.Length);
        return;
    }

    CWebServicesTaskResult_GhostScript@ task = CMAP.ScoreMgr.Map_GetRecordGhost_v2(
        App.UserManagerScript.Users[0].Id,
        App.RootMap.EdChallengeId,
        "PersonalBest",
        "",
        "TimeAttack",
        ""
    );

    while (task.IsProcessing)
        yield();

    if (task.HasSucceeded) {
        CGameGhostScript@ ghost = task.Ghost;
        if (ghost is null) {
            warn("null ghost");
            return;
        }

        CTmRaceResultNod@ result = ghost.Result;
        if (result is null) {
            warn("null result");
            return;
        }

        checkpoints.RemoveRange(0, checkpoints.Length);

        for (uint i = 0; i < result.Checkpoints.Length; i++)
            checkpoints.InsertLast(result.Checkpoints[i]);
    }
}
