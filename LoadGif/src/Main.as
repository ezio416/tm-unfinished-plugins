// c 2024-04-13
// m 2024-04-13

const string title = "\\$FFF" + Icons::Arrows + "\\$G Load GIF";

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;

UI::Texture@ tex;

void Main() {
    @tex = UI::LoadTexture("src/homer.gif");
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
        || tex is null
    )
        return;

    UI::Image(tex, vec2(200.0f, 200.0f));
}
