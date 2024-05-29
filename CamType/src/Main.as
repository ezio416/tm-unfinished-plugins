// c 2024-04-24
// m 2024-04-24

const string title = "\\$FFF" + Icons::Arrows + "\\$G Test_CamType";

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

iso4 location = iso4();

void Render() {
    if (!S_Enabled)
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CSmArenaClient@ Playground = cast<CSmArenaClient@>(App.CurrentPlayground);
    if (
        Playground is null
        || Playground.GameTerminals.Length == 0
        || Playground.GameTerminals[0] is null
    )
        return;

    const uint curCam = Dev::GetOffsetUint32(Playground.GameTerminals[0], 0x34);

    CDx11Viewport@ Viewport = cast<CDx11Viewport@>(App.Viewport);
    if (
        Viewport is null
        || Viewport.Cameras.Length < 2
        || Viewport.Cameras[1] is null
    )
        return;

    bool moving = false;

    if (DifferentIso4(location, Viewport.Cameras[1].NextLocation)) {
        location = Viewport.Cameras[1].NextLocation;
        moving = true;
    }

    if (UI::Begin(title, S_Enabled, UI::WindowFlags::None)) {
        UI::Text("cam: " + curCam);
        UI::Text("moving: " + moving);
    }

    UI::End();
}

bool DifferentIso4(const iso4 &in a, const iso4 &in b) {
    return a.tx != b.tx || a.ty != b.ty || a.tz != b.tz
        || a.xx != b.xx || a.xy != b.xy || a.xz != b.xz
        || a.yx != b.yx || a.yy != b.yy || a.yz != b.yz
        || a.zx != b.zx || a.zy != b.zy || a.zz != b.zz;
}
