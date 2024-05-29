// c 2024-04-11
// m 2024-04-14

const string title = "\\$FFF" + Icons::User + "\\$G Convert Account Login";

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

string accountId;
string login;

void Main() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    while (App.LocalPlayerInfo is null)
        yield();

    login = App.LocalPlayerInfo.Id.GetName();
}

void Render() {
    if (
        !S_Enabled
        || (S_HideWithGame && !UI::IsGameUIVisible())
        || (S_HideWithOP && !UI::IsOverlayShown())
        || login.Length == 0
    )
        return;

    if (UI::Begin(title, S_Enabled, UI::WindowFlags::AlwaysAutoResize)) {
        UI::Text("login: " + login);
        UI::Text("account ID: " + accountId);

        if (UI::Button("get account ID"))
            startnew(GetAccountId);
    }

    UI::End();
}

void GetAccountId() {
    MemoryBuffer@ buf = MemoryBuffer();
    buf.WriteFromBase64(login, true);

    const string hex = BufferToHex(buf);

    accountId = hex.SubStr(0, 8)
        + "-" + hex.SubStr(8, 4)
        + "-" + hex.SubStr(12, 4)
        + "-" + hex.SubStr(16, 4)
        + "-" + hex.SubStr(20);
}

const string BufferToHex(MemoryBuffer@ buf) {
    buf.Seek(0);

    string ret;

    for (uint i = 0; i < buf.GetSize(); i++) {
        const uint8 val = buf.ReadUInt8();
        ret += Uint4ToHex(val >> 4) + Uint4ToHex(val & 0xF);
    }

    return ret;
}

const string Uint4ToHex(const uint8 val) {
    string ret = " ";
    ret[0] = val < 10 ? val + 0x30 : val - 10 + 0x61;
    return ret;
}
