// c 2024-01-01
// m 2024-01-01

CTrackMania@             App;
CGameManiaAppPlayground@ CMAP;
CTrackManiaNetwork@      Network;
CSmArenaClient@          Playground;
CGamePlaygroundUIConfig@ UIConfig;

string title = "\\$FD4" + Icons::ListOl + "\\$G Leaderboard Expander";

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Number of extra positions" min=1 max=10]
uint S_Positions = 1;

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void Main() {
    @App = cast<CTrackMania@>(GetApp());

    while (true) {
        @Network = cast<CTrackManiaNetwork@>(App.Network);
        @CMAP = Network !is null ? Network.ClientManiaAppPlayground : null;
        @UIConfig = CMAP !is null ? CMAP.UI : null;
        @Playground = cast<CSmArenaClient@>(App.CurrentPlayground);
        yield();
    }
}

void Render() {
    if (!S_Enabled || App is null || App.RootMap is null || UIConfig is null)
        return;

    CGamePlaygroundUIConfig::EUISequence seq = UIConfig.UISequence;

    UI::Begin(title, S_Enabled);
        if (UI::BeginTable("##table", 2)) {
            UI::TableNextRow();
            UI::TableNextColumn(); UI::Text("RecordsElementVisible");
            UI::TableNextColumn(); UI::Text(PosNegColor(RecordsElementVisible()));

            UI::TableNextRow();
            UI::TableNextColumn(); UI::Text("SafeToCheckUI");
            UI::TableNextColumn(); UI::Text(PosNegColor(SafeToCheckUI()));

            UI::TableNextRow();
            UI::TableNextColumn(); UI::Text("ScoresTableVisible");
            UI::TableNextColumn(); UI::Text(PosNegColor(ScoresTableVisible()));

            UI::TableNextRow();
            UI::TableNextColumn(); UI::Text("SettingsOpen");
            UI::TableNextColumn(); UI::Text(PosNegColor(SettingsOpen()));

            UI::TableNextRow();
            UI::TableNextColumn(); UI::Text("UISequenceGood");
            UI::TableNextColumn(); UI::Text(PosNegColor(UISequenceGood(seq)));

            UI::TableNextRow();
            UI::TableNextColumn(); UI::Text("PlayingOrFinish");
            UI::TableNextColumn(); UI::Text(PosNegColor(UISequencePlayingOrFinish(seq)));

            UI::TableNextRow();
            UI::TableNextColumn(); UI::Text("UIPopulated");
            UI::TableNextColumn(); UI::Text(PosNegColor(UIPopulated()));

            UI::EndTable();
        }
    UI::End();
}
