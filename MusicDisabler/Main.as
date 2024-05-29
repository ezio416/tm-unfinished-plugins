// c 2024-01-30
// m 2024-01-30

const string title = "\\$FFF" + Icons::Arrows + "\\$G Music Disabler";

[Setting category="General" name="Enabled"]
bool S_Enabled = false;

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void Main() {
    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    while (true) {
        yield();

        if (!S_Enabled || App.RootMap is null)
            continue;

        if (App.RootMap.CustomMusic !is null)
            @App.RootMap.CustomMusic = null;

        if (App.RootMap.CustomMusicPackDesc !is null)
            @App.RootMap.CustomMusicPackDesc = null;
    }
}
