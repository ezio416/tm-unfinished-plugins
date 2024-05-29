// c 2024-01-14
// m 2024-01-14

string title = "\\$F41" + Icons::Download + "\\$G Download Killer";

void RenderMenu() {
    if (UI::MenuItem(title, "", S_Enabled))
        S_Enabled = !S_Enabled;
}

void Main() {
    while (true) {
        Loop();
        yield();
    }
}

void Loop() {
    if (!S_Enabled)
        return;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CTrackManiaNetwork@ Network = cast<CTrackManiaNetwork@>(App.Network);
    if (Network is null || Network.FileTransfer is null)
        return;

    for (int i = Network.FileTransfer.Downloads.Length - 1; i >= 0; i--) {
        if (Network.FileTransfer.Downloads[i] is null)
            continue;

        string name = string(Network.FileTransfer.Downloads[i].Name);
        uint size = GetSize(Network.FileTransfer.Downloads[i]);
        string sizeMB = GetSizeMB(size);
        DownloadType type = GetType(Network.FileTransfer.Downloads[i]);

        // if (size == 0)
        //     continue;

        // if (type == DownloadType::Unknown) {
            print("found (" + tostring(type) + "): " + name);
        //     UI::ShowNotification(title, name);
        // }

        if (
            S_All
            || (S_Music  && type == DownloadType::Music)
            || (S_Mods   && type == DownloadType::Mod && (S_MaxModSize == -1 || (S_MaxModSize > -1 && int(size) > S_MaxModSize * 1048576)))
            || (S_Skins  && type == DownloadType::Skin)
            || (S_Signs  && type == DownloadType::Sign)
            || (S_Sounds && type == DownloadType::Sound)
        ) {
            trace("killing " + name + " (" + sizeMB + ")");
            @Network.FileTransfer.Downloads[i] = null;
        }
    }
}

enum DownloadType {
    Mod,
    Music,
    Skin,
    Sign,
    Sound,
    All,
    Other,
    Unknown
}

uint GetSize(CNetFileTransferDownload@ Download) {
    if (Download is null || Download.ActiveUrlSource is null || Download.ActiveUrlSource.MasterServerDownload is null)
        return 0;

    CNetHttpResult@ HttpResult = cast<CNetMasterServerDownload@>(Download.ActiveUrlSource.MasterServerDownload).HttpResult;
    if (HttpResult is null)
        return 0;

    return HttpResult.ExpectedTransfertSize;
}

string GetSizeMB(uint size) {
    return Text::Format("%.1f", float(size) / 1048576) + "MB";
}

DownloadType GetType(CNetFileTransferDownload@ Download) {
    if (Download is null)
        return DownloadType::Unknown;

    string[] path = string(Download.Name).Split("\\");

        if (path[0] == "Media") {
            if (path[1] == "Musics")
                return DownloadType::Music;

            if (path[1] == "Sounds")
                return DownloadType::Sound;

        } else if (path[0] == "Skins") {
            if (path[1] == "Any" && path[2].StartsWith("Advertisement"))
                return DownloadType::Sign;

            if (path[1] == "Models" && path[2] == "CarSport")
                return DownloadType::Skin;

            if (path[1] == "Stadium" && path[2] == "Mod")
                return DownloadType::Mod;

        } else if (path[0].StartsWith("trackmania-prod"))
            return DownloadType::Other;

    return DownloadType::Unknown;
}
