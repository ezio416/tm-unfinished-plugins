// c 2024-01-01
// m 2024-01-01

uint lastRecordsLayerIndex = 14;

bool FindUIElements() {
    if (CMAP is null)
        return false;

    uint nbLayers = CMAP.UILayers.Length;

    bool foundRecordsLayer = lastRecordsLayerIndex < nbLayers &&
        UILayerMatches(CMAP.UILayers[lastRecordsLayerIndex], "UIModule_Race_Record");

    if (!foundRecordsLayer) {
        // don't check very early layers -- might sometimes crash the game?
        for (uint i = 3; i < nbLayers; i++) {
            if (UILayerMatches(CMAP.UILayers[i], "UIModule_Race_Record")) {
                lastRecordsLayerIndex = i;
                return true;
            }
        }
    }

    return foundRecordsLayer;
}

// bool backToRaceFromGhostVisible = false;
// CGameManialinkFrame@ frameNoRecords;
// CGameManialinkFrame@ hidePbFrame;
// vec2 mainFrameAbsPos;
// float mainFrameAbsScale = 0.0f;
// uint nbRecordsShown = 0;
// CGameManialinkFrame@ raceRecordFrame;
// CGameManialinkFrame@ rankingsFrame;
// CGameManialinkControl@ slideFrame;
// float slideFrameProgress = 1.0f;

// doesn't seem to work
// bool RecordsElementVisible() {
//     if (CMAP is null)
//         return false;

//     if (slideFrame is null || raceRecordFrame is null) {
//         if (lastRecordsLayerIndex >= CMAP.UILayers.Length)
//             return false;

//         CGameUILayer@ layer = CMAP.UILayers[lastRecordsLayerIndex];
//         if (layer is null)
//             return false;

//         CGameManialinkFrame@ frame = cast<CGameManialinkFrame@>(layer.LocalPage.GetFirstChild("frame-records"));
//         if (frame is null)
//             return false;

//         @raceRecordFrame = cast<CGameManialinkFrame@>(frame.Parent);
//         if (raceRecordFrame is null)
//             return false;

//         // should always be visible
//         if (frame is null || !frame.Visible)
//             return false;

//         if (frame.Controls.Length < 2)
//             return false;

//         @slideFrame = frame.Controls[1];
//         if (slideFrame.ControlId != "frame-slide")
//             throw("should be slide-frame");

//         @rankingsFrame = cast<CGameManialinkFrame@>(raceRecordFrame.GetFirstChild("frame-ranking"));
//         @hidePbFrame = cast<CGameManialinkFrame@>(raceRecordFrame.GetFirstChild("frame-toggle-pb"));
//         @frameNoRecords = cast<CGameManialinkFrame@>(raceRecordFrame.GetFirstChild("frame-no-records"));
//         CGameManialinkControl@ backBtn = raceRecordFrame.GetFirstChild("button-back-to-race");
//         backToRaceFromGhostVisible = backBtn !is null && backBtn.Visible;
//     }

//     if (raceRecordFrame !is null && !raceRecordFrame.Visible)
//         return false;

//     if (slideFrame.Parent !is null && !slideFrame.Parent.Visible)
//         return false;

//     if (rankingsFrame !is null) {
//         nbRecordsShown = 0;

//         for (uint i = 0; i < rankingsFrame.Controls.Length; i++) {
//             if (rankingsFrame.Controls[i].Visible)
//                 nbRecordsShown++;
//         }

//         if (hidePbFrame !is null && hidePbFrame.Visible)
//             nbRecordsShown++;

//         if (frameNoRecords !is null && frameNoRecords.Visible)
//             nbRecordsShown++;
//     }

//     mainFrameAbsPos = raceRecordFrame.AbsolutePosition_V3;
//     mainFrameAbsScale = raceRecordFrame.AbsoluteScale;

//     // if the abs scale is too low (or negative) it causes problems. no legit case is like this so just set to 1
//     if (mainFrameAbsScale <= 0.05f)
//         mainFrameAbsScale = 1.0f;

//     slideFrameProgress = (slideFrame.RelativePosition_V3.x + 61.0f) / 61.0f;

//     return slideFrameProgress > 0.0f;
// }

float slideFrameProgress = 1.0f;

CGameManialinkControl@ slideFrame = null;
CGameManialinkFrame@ Race_Record_Frame = null;
CGameManialinkFrame@ rankingsFrame = null;
CGameManialinkFrame@ hidePbFrame = null;
CGameManialinkFrame@ frameNoRecords = null;
bool backToRaceFromGhostVisible = false;
vec2 mainFrameAbsPos;
float mainFrameAbsScale;
uint nbRecordsShown = 0;

bool RecordsElementVisible() {
    if (CMAP is null)
        return false;

    if (slideFrame is null || Race_Record_Frame is null) {
        if (lastRecordsLayerIndex >= CMAP.UILayers.Length)
            return false;

        CGameUILayer@ layer = CMAP.UILayers[lastRecordsLayerIndex];
        if (layer is null)
            return false;

        auto frame = cast<CGameManialinkFrame@>(layer.LocalPage.GetFirstChild("frame-records"));
        if (frame is null)
            return false;

        @Race_Record_Frame = cast<CGameManialinkFrame@>(frame.Parent);
        if (Race_Record_Frame is null)
            return false;

        // should always be visible
        if (frame is null || !frame.Visible)
            return false;

        if (frame.Controls.Length < 2)
            return false;

        @slideFrame = frame.Controls[1];
        if (slideFrame.ControlId != "frame-slide")
            throw("should be slide-frame");

        @rankingsFrame = cast<CGameManialinkFrame@>(Race_Record_Frame.GetFirstChild("frame-ranking"));
        @hidePbFrame = cast<CGameManialinkFrame@>(Race_Record_Frame.GetFirstChild("frame-toggle-pb"));
        @frameNoRecords = cast<CGameManialinkFrame@>(Race_Record_Frame.GetFirstChild("frame-no-records"));
        auto backBtn = Race_Record_Frame.GetFirstChild("button-back-to-race");
        backToRaceFromGhostVisible = backBtn !is null && backBtn.Visible;
    }

    if (Race_Record_Frame !is null && !Race_Record_Frame.Visible)
        return false;

    if (slideFrame.Parent !is null && !slideFrame.Parent.Visible)
        return false;

    if (rankingsFrame !is null) {
        nbRecordsShown = 0;

        for (uint i = 0; i < rankingsFrame.Controls.Length; i++) {
            auto item = rankingsFrame.Controls[i];
            if (item.Visible)
                nbRecordsShown++;
        }

        if (hidePbFrame !is null && hidePbFrame.Visible)
            nbRecordsShown++;

        if (frameNoRecords !is null && frameNoRecords.Visible)
            nbRecordsShown++;
    }

    mainFrameAbsPos = Race_Record_Frame.AbsolutePosition_V3;
    mainFrameAbsScale = Race_Record_Frame.AbsoluteScale;
    // if the abs scale is too low (or negative) it causes problems. no legit case is like this so just set to 1
    if (mainFrameAbsScale <= 0.05f)
        mainFrameAbsScale = 1.0f;
    slideFrameProgress = (slideFrame.RelativePosition_V3.x + 61.0f) / 61.0f;

    return slideFrameProgress > 0.0f;
}

bool SafeToCheckUI() {
    return !(
        App.RootMap is null ||
        Playground is null ||
        App.Editor !is null ||
        !UIPopulated()
    );
}

bool ScoresTableVisible() {
    if (CMAP is null)
        return false;

    for (uint i = 2; i < uint(Math::Min(8, CMAP.UILayers.Length)); i++) {
        CGameUILayer@ Layer = CMAP.UILayers[i];

        if (Layer !is null && Layer.Type == CGameUILayer::EUILayerType::ScoresTable)
            return Layer.LocalPage !is null && Layer.LocalPage.MainFrame !is null && Layer.LocalPage.MainFrame.Visible;
    }

    return false;
}

// doesn't seem to work or idk what it is
bool SettingsOpen() {
    CHmsViewport@ Viewport = App.Viewport;

    if (Viewport.Overlays.Length < 3)
        return false;

    // 5 normally, report/key have 15 and 24; menu open has like 390
    // prior strat was satatic 10 but that doesn't work. (I had it at index 14 out of 17 total elements)
    // note: overlay has sort order 14, mb filter on that
    return Viewport.Overlays[Viewport.Overlays.Length - 3].m_CorpusVisibles.Length > 10;
}

bool UILayerMatches(CGameUILayer@ Layer, const string &in manialinkName) {
    if (Layer is null)
        return false;

    // accessing ManialinkPageUtf8 in some cases might crash the game
    if (Layer.ManialinkPage.Length < 10)
        return false;

    return string(Layer.ManialinkPage.SubStr(0, 127)).Trim().StartsWith("<manialink name=\"" + manialinkName);
}

bool UISequenceGood(CGamePlaygroundUIConfig::EUISequence uiSeq) {
    return uiSeq == CGamePlaygroundUIConfig::EUISequence::Playing ||
        uiSeq == CGamePlaygroundUIConfig::EUISequence::Finish ||
        uiSeq == CGamePlaygroundUIConfig::EUISequence::EndRound ||
        uiSeq == CGamePlaygroundUIConfig::EUISequence::UIInteraction;
}

bool UISequencePlayingOrFinish(CGamePlaygroundUIConfig::EUISequence seq) {
    return seq == CGamePlaygroundUIConfig::EUISequence::Playing ||
        seq == CGamePlaygroundUIConfig::EUISequence::Finish;
}

uint lastNbUilayers = 0;

bool UIPopulated() {
    if (CMAP is null || UIConfig is null || Playground is null || Playground.UIConfigs.Length == 0)
        return false;

    if (!UISequenceGood(UIConfig.UISequence))
        return false;

    uint nbUiLayers = CMAP.UILayers.Length;

    // if the number of UI layers decreases it's probably due to a recovery restart, so we don't want to act on old references
    if (nbUiLayers <= 2 || nbUiLayers < lastNbUilayers)
        return false;

    lastNbUilayers = nbUiLayers;

    return true;
}
