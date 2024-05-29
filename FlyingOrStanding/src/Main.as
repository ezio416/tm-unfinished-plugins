// c 2024-03-07
// m 2024-03-07

const string title = "\\$FFF" + Icons::Arrows + "\\$G Flying Or Standing";

void Main() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    uint lastRespawns = 0;

    while (true) {
        yield();

        CSmArenaClient@ Playground = cast<CSmArenaClient@>(App.CurrentPlayground);
        if (Playground is null)
            continue;

        ISceneVis@ Scene = App.GameScene;
        if (Scene is null)
            continue;

        CSmPlayer@ Player = VehicleState::GetViewingPlayer();
        if (Player is null)
            continue;

        CSmArenaScore@ Score = Player.Score;
        if (Score is null)
            continue;

        CSceneVehicleVis@ Vis = VehicleState::GetVis(Scene, Player);
        if (Vis is null)
            continue;

        CSceneVehicleVisState@ State = Vis.AsyncState;
        if (State is null)
            continue;

        if (Score.NbRespawnsRequested != lastRespawns) {
            lastRespawns = Score.NbRespawnsRequested;
            yield();
            print(State.WorldVel.Length() == 0.0f ? "standing" : "flying");
        }
    }
}
