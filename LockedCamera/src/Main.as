/*
c 2023-08-02
m 2024-01-17
*/

// const uint ActiveCamControlOffset = 0x68;
[Setting hidden]
bool S_Enabled = false;
// bool flip = false;
const string title = "\\$C11" + Icons::VideoCamera + "\\$G " + Meta::ExecutingPlugin().Name;

// void Main() { }
// void OnDestroyed() { }
// void OnDisabled() { OnDestroyed(); }

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled)) {
        S_Enabled = !S_Enabled;
    }
}

void Render() {
    if (!S_Enabled)
        return;

    // if (flip) {
    //     SetCamChoice(CamChoice::Cam1Alt);
    //     flip = false;
    // } else {
    //     SetCamChoice(CamChoice::Cam1);
    //     flip = true;
    // }

    CTrackMania@ App = cast<CTrackMania@>(GetApp());
    CSmArenaClient@ Playground = cast<CSmArenaClient@>(App.CurrentPlayground);
    if (Playground is null)
        return;

    CDx11Viewport@ Viewport = cast<CDx11Viewport@>(App.Viewport);
    if (Viewport is null || Viewport.Cameras.Length < 3)
        return;

    CHmsCamera@ Camera1 = Viewport.Cameras[1];
    if (Camera1 is null)
        return;

    CHmsCamera@ Camera2 = Viewport.Cameras[2];
    if (Camera2 is null)
        return;

    ISceneVis@ Scene = App.GameScene;
    if (Scene is null)
        return;

    // CameraStatus@ status = GetCameraStatus();

    CSmPlayer@ Player = cast<CSmPlayer@>(App.CurrentPlayground.GameTerminals[0].GUIPlayer);
    CSceneVehicleVis@ Vis = Player is null ? VehicleState::GetSingularVis(Scene) : VehicleState::GetVis(Scene, Player);
    if (Vis is null) {
        warn("null Vis");
        return;
    }
    CSceneVehicleVisState@ State = Vis.AsyncState;

    iso4 Location = Camera1.Location;
    Location = iso4(mat4(
        vec4(State.Left.x, Location.xy, Location.xz, 0),
        vec4(Location.yx,  Location.yy, Location.yz, 0),
        vec4(Location.zx,  Location.zy, Location.zz, 0),
        vec4(Location.tx,  Location.ty, Location.tz, 0)
    ));

    UI::Begin(title, S_Enabled, UI::WindowFlags::None);
        UI::Separator();
        UI::Text("Camera1.NextLocation old");
        UI::Text(Round(Camera1.NextLocation));

        UI::Separator();
        UI::Text("Camera1.Location old");
        UI::Text(Round(Camera1.Location));

        UI::Separator();
        UI::Text("Location new");
        UI::Text(Round(Location));

        UI::Separator();
        UI::Text("Camera1.NextLocation new");
        Camera1.NextLocation = Location;
        UI::Text(Round(Camera1.NextLocation));

        UI::Separator();
        UI::Text("Camera1.Location new");
        Camera1.Location = Location;
        UI::Text(Round(Camera1.Location));
    UI::End();

}

const string BLUE   = "\\$09D";
const string CYAN   = "\\$2FF";
const string GRAY   = "\\$888";
const string GREEN  = "\\$0D2";
const string ORANGE = "\\$F90";
const string PURPLE = "\\$F0F";
const string RED    = "\\$F00";
const string WHITE  = "\\$FFF";
const string YELLOW = "\\$FF0";

string Round(float num, uint precision = 3) {
    return (num == 0 ? WHITE : num < 0 ? RED : GREEN) + Text::Format("%." + precision + "f", Math::Abs(num));
}

string Round(iso4 iso, uint precision = 3) {
    string ret;

    ret += Round(iso.xx, precision) + "\\$G , " + Round(iso.xy, precision) + "\\$G , " + Round(iso.xz, precision) + "\n";
    ret += Round(iso.yx, precision) + "\\$G , " + Round(iso.yy, precision) + "\\$G , " + Round(iso.yz, precision) + "\n";
    ret += Round(iso.zx, precision) + "\\$G , " + Round(iso.zy, precision) + "\\$G , " + Round(iso.zz, precision) + "\n";
    ret += Round(iso.tx, precision) + "\\$G , " + Round(iso.ty, precision) + "\\$G , " + Round(iso.tz, precision);

    return ret;
}

// void SetCamChoice(CamChoice cam) {
//     bool alt = cam == CamChoice::Cam1Alt || cam == CamChoice::Cam2Alt;
//     CameraType type = (cam == CamChoice::Cam1 || cam == CamChoice::Cam1Alt) ? CameraType::Cam1 : CameraType::Cam2;
//     auto app = GetApp();
//     SetAltCamFlag(app, alt);
//     SetCamType(app, type);
// }

class CameraStatus {
    bool isAlt;
    bool canDrive;
    uint currCam;

    CameraStatus() { }
    CameraStatus(bool isAlt, bool canDrive, uint currCam) {
        this.isAlt = isAlt;
        this.canDrive = canDrive;
        this.currCam = currCam;
    }

    string ToString() const {
        if (currCam == 0)
            return "None";

        return tostring(CameraType(currCam)) + " [" + tostring(CGameItemModel::EnumDefaultCam(currCam)) + "]" + (isAlt ? " (alt)" : "") + (canDrive ? " (drivable)" : "");
    }
}

CameraStatus@ GetCameraStatus() {
    auto gt = GetGameTerminal(GetApp());
    if (gt is null)
        return CameraStatus();

    bool alt      = Dev::GetOffsetUint16(gt, 0x30) == 0;
    bool canDrive = Dev::GetOffsetUint32(gt, 0x60) == 0;
    uint currCam  = Dev::GetOffsetUint32(gt, 0x34);

    return CameraStatus(alt, canDrive, currCam);
}

CGameTerminal@ GetGameTerminal(CGameCtnApp@ app) {
    if (app.CurrentPlayground is null)
        return null;

    if (app.CurrentPlayground.GameTerminals.Length == 0)
        return null;

    auto gt = app.CurrentPlayground.GameTerminals[0];

    return gt;
}

// void SetAltCamFlag(CGameCtnApp@ app, bool isAlt) {
//     auto gt = GetGameTerminal(app);
//     if (gt is null) return;
//     Dev::SetOffset(gt, 0x30, isAlt ? 0x0 : 0x1);
// }

// crashes on 0x8, 0x9, and 0x1e or greater
// 3,4,5,6 are some kind of default cams where you need to toggle free cam drivable to drive
enum CameraType {
    FreeCam      = 2,
    WeirdDefault = 5,
    Intro7Mb     = 7,
    Intro10Mb    = 16,
    FreeCam2     = 17,
    Cam1         = 18,
    Cam2         = 19,
    Cam3         = 20,
    Backwards    = 21,
    Intro16Mb    = 22,
    // same repeated up to 0x1d
    // Intro1dMb = 0x1d,
}

// void SetCamType(CGameCtnApp@ app, CameraType cam) {
//     auto gt = GetGameTerminal(app);
//     if (gt is null) return;
// 	auto setCamNod = Dev::GetOffsetNod(gt, 0x50);
//     Dev::SetOffset(setCamNod, 0x4, uint(cam));
// }

// enum CamChoice {
//     Cam1, Cam1Alt,
//     Cam2, Cam2Alt,
//     Cam3, Cam3Alt
// }

// [SettingsTab name="Debug"]
// void S_DebugTab() {
//     UI::TextWrapped("Current Camera: " + GetCameraStatus().ToString());

//     if (UI::Button("Set Cam1")) {
//         SetCamChoice(CamChoice::Cam1);
//     }
//     if (UI::Button("Set Cam1Alt")) {
//         SetCamChoice(CamChoice::Cam1Alt);
//     }
//     if (UI::Button("Set Cam2")) {
//         SetCamChoice(CamChoice::Cam2);
//     }
//     if (UI::Button("Set Cam2Alt")) {
//         SetCamChoice(CamChoice::Cam2Alt);
//     }
// }
