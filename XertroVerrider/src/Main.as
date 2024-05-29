/*
c 2023-09-26
m 2023-11-26
*/

[Setting hidden]
bool aho = false;

[Setting hidden]
string ahoVersion;

[Setting hidden]
bool epp = false;

[Setting hidden]
string eppVersion;

[Setting hidden]
bool gpp = false;

[Setting hidden]
string gppVersion;

[Setting hidden]
bool remember = false;

bool ahoAlreadySafe = false;
bool ahoOverridden  = false;

bool eppAlreadySafe = false;
bool eppOverridden  = false;

bool gppAlreadySafe = false;
bool gppOverridden  = false;

bool safetyPreChecked = false;
string title = Icons::Repeat + " XertroVerrider";

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

void Main() {
    string version;

#if DEPENDENCY_AUTOHIDEOPPONENTS
    try {
        version = Meta::GetPluginFromID("AutohideOpponents").Version;
        if (ahoVersion != version) {
            if (!remember)
                aho = false;
            ahoVersion = version;
        }

        ahoAlreadySafe = IsGameVersionSafe_AutoHideOpponents();
    } catch {
        warn("Auto-hide Opponents: " + getExceptionInfo());
    }
#endif

#if DEPENDENCY_EDITOR
    try {
        version = Meta::GetPluginFromID("Editor").Version;
        if (eppVersion != version) {
            if (!remember)
                epp = false;
            eppVersion = version;
        }

        eppAlreadySafe = IsGameVersionSafe_EditorPP();
    } catch {
        warn("Editor++: " + getExceptionInfo());
    }
#endif

#if DEPENDENCY_GHOSTS_PP
    try {
        version = Meta::GetPluginFromID("ghosts-pp").Version;
        if (gppVersion != version) {
            if (!remember)
                gpp = false;
            gppVersion = version;
        }

        gppAlreadySafe = IsGameVersionSafe_GhostsPP();
    } catch {
        warn("Ghosts++: " + getExceptionInfo());
    }
#endif

    safetyPreChecked = true;
}

void OnDestroyed() { Reset(); }
void OnDisabled() { Reset(); }

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

#if DEPENDENCY_AUTOHIDEOPPONENTS
import void OverrideGameSafetyCheck_AutoHideOpponents(bool safe = true) from "AutoHideOpponents";
import bool IsGameVersionSafe_AutoHideOpponents() from "AutoHideOpponents";
#endif

#if DEPENDENCY_GHOSTS_PP
import void OverrideGameSafetyCheck_EditorPP(bool safe = true) from "Editor_PP";
import bool IsGameVersionSafe_EditorPP() from "Editor_PP";
#endif

#if DEPENDENCY_GHOSTS_PP
import void OverrideGameSafetyCheck_GhostsPP(bool safe = true) from "Ghosts_PP";
import bool IsGameVersionSafe_GhostsPP() from "Ghosts_PP";
#endif

void Render() {
    if (!S_Enabled || !safetyPreChecked)
        return;

    UI::Begin(title, S_Enabled, UI::WindowFlags::AlwaysAutoResize);
        // UI::TextWrapped("XertroV makes some plugins that require manual review before they work on a new game version. This is smart, but it could be annoying if you feel comfortable taking risks. Below are the plugins you have installed which do this.");
        // UI::TextWrapped("If a plugin's name is green, that means it is already safe to run on the current game version.");

        remember = UI::Checkbox("Remember choices (unsafe)", remember);
        if (!remember) {
            if (aho && ahoOverridden)
                aho = false;
            if (epp && eppOverridden)
                epp = false;
            if (gpp && gppOverridden)
                gpp = false;
        }

        if (UI::Button("Reset choices"))
            Reset();

#if DEPENDENCY_AUTOHIDEOPPONENTS
        UI::Separator();
        UI::Text((ahoAlreadySafe ? "\\$0F0" : "") + "Auto-hide Opponents");

        try {
            bool ahoSafe = IsGameVersionSafe_AutoHideOpponents();
            if (remember && aho && !ahoSafe && !ahoOverridden) {
                OverrideAutoHideOpponents();
                ahoOverridden = true;
            }
            if (UI::Button("Run Anyway " + (ahoSafe ? Icons::ToggleOn : Icons::ToggleOff) + "##aho")) {
                aho = !ahoSafe;
                OverrideAutoHideOpponents(aho);
            }
        } catch {
            UI::Text("Error: " + getExceptionInfo());
        }
#endif

#if DEPENDENCY_EDITOR
        UI::Separator();
        UI::Text((eppAlreadySafe ? "\\$0F0" : "") + "Editor++");

        try {
            bool eppSafe = IsGameVersionSafe_EditorPP();
            if (remember && epp && !eppSafe && !eppOverridden) {
                OverrideEditorPP();
                eppOverridden = true;
            }
            if (UI::Button("Run Anyway " + (eppSafe ? Icons::ToggleOn : Icons::ToggleOff) + "##epp")) {
                epp = !eppSafe;
                OverrideEditorPP(epp);
            }
        } catch {
            UI::Text("Error: " + getExceptionInfo());
        }
#endif

#if DEPENDENCY_GHOSTS_PP
        UI::Separator();
        UI::Text((gppAlreadySafe ? "\\$0F0" : "") + "Ghosts++");

        try {
            bool gppSafe = IsGameVersionSafe_GhostsPP();
            if (remember && gpp && !gppSafe && !gppOverridden) {
                OverrideGhostsPP();
                gppOverridden = true;
            }
            if (UI::Button("Run Anyway " + (gppSafe ? Icons::ToggleOn : Icons::ToggleOff) + "##gpp")) {
                gpp = !gppSafe;
                OverrideGhostsPP(gpp);
            }
        } catch {
            UI::Text("Error: " + getExceptionInfo());
        }
#endif

    UI::End();
}

#if DEPENDENCY_AUTOHIDEOPPONENTS
void OverrideAutoHideOpponents(bool safe = true) {
    trace((safe ? "" : "de-") + "overriding Auto-hide Opponents");
    OverrideGameSafetyCheck_AutoHideOpponents(safe);
}
#endif

#if DEPENDENCY_EDITOR
void OverrideEditorPP(bool safe = true) {
    trace((safe ? "" : "de-") + "overriding Editor++");
    OverrideGameSafetyCheck_EditorPP(safe);
}
#endif

#if DEPENDENCY_GHOSTS_PP
void OverrideGhostsPP(bool safe = true) {
    trace((safe ? "" : "de-") + "overriding Ghosts++");
    OverrideGameSafetyCheck_GhostsPP(safe);
}
#endif

void Reset() {
    trace("resetting...");

#if DEPENDENCY_AUTOHIDEOPPONENTS
    try {
        OverrideAutoHideOpponents(ahoAlreadySafe);
    } catch { }
#endif

#if DEPENDENCY_EDITOR
    try {
        OverrideEditorPP(eppAlreadySafe);
    } catch { }
#endif

#if DEPENDENCY_GHOSTS_PP
    try {
        OverrideGhostsPP(gppAlreadySafe);
    } catch { }
#endif
}
