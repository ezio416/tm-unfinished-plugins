// c 2024-03-09
// m 2024-03-09

const string path = "C:/Users/Ezio/Documents/Trackmania/Skins/Stadium/Mod/TMWC_v4.zip";
string hash;
const string title = "\\$FFF" + Icons::Arrows + "\\$G Checksums";

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

    if (UI::Button("get sha256"))
        startnew(Sha256);

    UI::Text(hash);
}

void Sha256() {
    uint64 now = Time::Now;
    print("start " + now);

    IO::File file(path, IO::FileMode::Read);
    const string contents = file.ReadToEnd();
    file.Close();

    print("file read after " + (Time::Now - now) + " ms");

    hash = Crypto::Sha256(contents).ToUpper();

    print("done after " + (Time::Now - now) + " ms");
}