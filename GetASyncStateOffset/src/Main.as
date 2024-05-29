// c 2024-01-10
// m 2024-01-10

string title = "GetASyncStateOffset";

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void Render() {
    if (!S_Enabled)
        return;

    UI::Begin(title, S_Enabled, UI::WindowFlags::None);
        CTrackMania@ App = cast<CTrackMania@>(GetApp());

        CSmArenaClient@ Playground = cast<CSmArenaClient@>(App.CurrentPlayground);
        if (Playground !is null) {
            ISceneVis@ Scene = cast<ISceneVis@>(App.GameScene);
            if (Scene !is null) {
                try {
                    CSmPlayer@ Player = cast<CSmPlayer@>(Playground.GameTerminals[0].GUIPlayer);
                    CSceneVehicleVis@ Vis = Player !is null ? VehicleState::GetVis(Scene, Player) : VehicleState::GetSingularVis(Scene);
                    CSceneVehicleVisState@ State;

                    int offsetFound = -1;
                    for (int i = 4; i < 1000; i++) {
                        int offset = i * 4;

                        try {
                            uint64 ptr = Dev::GetOffsetUint64(Vis, offset);
                            if (ptr & 0xF != 0)
                                continue;

                            print("pointer at " + offset);

                            @State = cast<CSceneVehicleVisState@>(Dev::GetOffsetNod(Vis, offset));
                            if (State !is null) {
                                offsetFound = int(i);
                                break;
                            }
                        } catch { }
                    }

                    UI::Text("pointer found at " + offsetFound);
                    if (State !is null) {
                        UI::Text(tostring(State.Position));
                    } else
                        UI::Text("null State");

                } catch {
                    UI::Text(getExceptionInfo());
                }

            } else
                UI::Text("null Scene");

        } else
            UI::Text("null Playground");

    UI::End();
}
