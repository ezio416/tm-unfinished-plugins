// c 2024-03-14
// m 2024-05-28

const string title = "\\$FFF" + Icons::Arrows + "\\$G Model Handles";

[Setting category="General" name="Enabled"]
bool S_Enabled = true;

[Setting category="General" name="Show/hide with game UI"]
bool S_HideWithGame = true;

[Setting category="General" name="Show/hide with Openplanet UI"]
bool S_HideWithOP = false;

// void OnDestroyed() { RemoveModelRefs(); }
// void OnDisabled()  { RemoveModelRefs(); }

void Main() {
    startnew(AddModelRefs);
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

    // UI::Text("LoadedNod offset: " + GetMemberOffset("CGameCtnArticle", "LoadedNod"));

    // CheckModels();

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CSmArenaClient@ Playground = cast<CSmArenaClient@>(App.CurrentPlayground);
    if (
        App.GameScene is null
        || Playground is null
        || Playground.Arena is null
        || Playground.Arena.Resources is null
        || Playground.GameTerminals.Length == 0
        || Playground.GameTerminals[0] is null
    )
        return;

    // MwFastBuffer<CGameItemModel@> Models = Playground.Arena.Resources.m_AllGameItemModels;
    // if (Models.Length == 0)
    //     return;

    CSmPlayer@ Player = cast<CSmPlayer@>(Playground.GameTerminals[0].GUIPlayer);

    CSceneVehicleVis@ Vis = Player !is null ? VehicleState::GetVis(App.GameScene, Player) : VehicleState::GetSingularVis(App.GameScene);
    if (Vis is null)
        return;

    CSceneVehicleVisState@ State = Vis.AsyncState;
    if (State is null)
        return;

    // const int index = GetVehicleResourceIndex(State);

    // UI::Text("index: " + index);

    // CGameItemModel@ Model;

    // if (index < int(Models.Length))
    //     @Model = Models[index];

    // if (Model is null)
    //     return;

    VehicleType vehicle = GetVehicleType(State);
    UI::Text(tostring(vehicle));

    // UI::Text("CarSport: " + bool(Model is App.GlobalCatalog.Chapters[1].Articles[0].LoadedNod));
    // UI::Text("CarSnow: "  + bool(Model is App.GlobalCatalog.Chapters[1].Articles[1].LoadedNod));
    // UI::Text("CarRally: " + bool(Model is App.GlobalCatalog.Chapters[1].Articles[2].LoadedNod));

    // if (parent !is null) {
    //     if (UI::Button("explore parent"))
    //         ExploreNod(parent);
    // }

    if (nods.Length > 0) {
        for (uint i = 0; i < nods.Length; i++) {
            if (nods[i] !is null) {
                if (UI::Button("explore " + i))
                    ExploreNod(nods[i]);
            } else
                UI::Text("null nod " + i);
        }
    } else
        UI::Text("no nods");
}

uint16 GetMemberOffset(const string &in className, const string &in memberName) {
    const Reflection::MwClassInfo@ type = Reflection::GetType(className);

    if (type is null)
        throw("Unable to find reflection info for \"" + className + "\"");

    const Reflection::MwMemberInfo@ member = type.GetMember(memberName);

    if (member is null)
        throw("Unable to find member \"" + memberName + "\" in \"" + className + "\"");

    return member.Offset;
}

// uint16 vehicleModelIndexOffset = 0;

// int GetVehicleResourceIndex(CSceneVehicleVisState@ State) {
//     if (vehicleModelIndexOffset == 0)
//         vehicleModelIndexOffset = GetMemberOffset("CSceneVehicleVisState", "InputSteer") - 8;

//     return int(Dev::GetOffsetUint8(State, vehicleModelIndexOffset));
// }

// CGameItemModel@ CarSport;
// CGameItemModel@ CarSnow;
// CGameItemModel@ CarRally;
// CGameItemModel@ CharacterPilot;

// CGameItemModel@ GetVehicleModel(uint16 index) {
//     CTrackMania@ App = cast<CTrackMania@>(GetApp());
//     CSmArenaClient@ Playground = cast<CSmArenaClient@>(App.CurrentPlayground);

//     if (
//         Playground is null
//         || Playground.Arena is null
//         || Playground.Arena.Resources is null
//         || Playground.Arena.Resources.m_AllGameItemModels.Length < index
//     )
//         return null;

//     return null;
// }

CMwNod@[] nods;

void AddModelRefs() {
    print("adding model refs");

    // CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CSystemFidsFolder@ parentFolder = Fids::GetGameFolder("GameData/Vehicles/Items/Cars");
    if (parentFolder !is null) {
        for (uint i = 0; i < parentFolder.Leaves.Length; i++) {
            print("adding file " + i);
            CMwNod@ nod = Fids::Preload(parentFolder.Leaves[i]);
            bool exists = false;
            for (uint j = 0; j < nods.Length; j++) {
                if (nods[j] is nod)
                    exists = true;
            }
            if (!exists) {
                print("nod " + i + " not found, adding");
                nods.InsertLast(nod);
            } else
                print("nod " + i + " already exists in nods");
        }
    } else
        warn("null parentFolder");

//     while (true) {
//         yield();

//         CSmArenaClient@ Playground = cast<CSmArenaClient@>(App.CurrentPlayground);
//         if (Playground is null)
//             continue;

//         CGameCtnCatalog@ Catalog = App.GlobalCatalog;
//         if (Catalog is null)
//             continue;

//         MwFastBuffer<CGameCtnChapter@> Chapters = Catalog.Chapters;
//         if (Chapters.Length < 2)
//             continue;

//         CGameCtnChapter@ Chapter = Chapters[1];
//         if (Chapter is null)
//             continue;

//         MwFastBuffer<CGameCtnArticle@> Articles = Chapter.Articles;
//         if (Articles.Length < 4)
//             continue;

//         for (uint i = 0; i < Articles.Length; i++) {
//             CGameItemModel@ Model = cast<CGameItemModel@>(Articles[i].LoadedNod);
//             if (Model is null)
//                 break;

//             if (CarSport is null && Model.Name == "CarSport")  // 0x40004c95
//                 @CarSport = Model;
//             else if (CarSnow is null && Model.Name == "CarSnow")  // 400016d9
//                 @CarSnow = Model;
//             else if (CarRally is null && Model.Name == "CarRally")  // 40003ce4
//                 @CarRally = Model;
//             else if (CharacterPilot is null && Model.Name == "CharacterPilot")  // 4000625b
//                 @CharacterPilot = Model;
//         }

//         if (CarSport !is null && CarSnow !is null && CarRally !is null && CharacterPilot !is null) {
//             // CarSport.MwAddRef();
//             // CarSnow.MwAddRef();
//             // CarRally.MwAddRef();
//             // CharacterPilot.MwAddRef();
//             return;
//         } else {
//             @CarSport = null;
//             @CarSnow = null;
//             @CarRally = null;
//             @CharacterPilot = null;
//         }
//     }
}

enum VehicleType {
    CharacterPilot,
    CarSport,
    CarSnow,
    CarRally,
    // CarDesert
}

uint16 vehicleTypeOffset = 0;

VehicleType GetVehicleType(CSceneVehicleVisState@ State) {
    if (vehicleTypeOffset == 0)
        vehicleTypeOffset = GetMemberOffset("CSceneVehicleVisState", "InputSteer") - 8;

    CTrackMania@ App = cast<CTrackMania@>(GetApp());

    CSmArenaClient@ Playground = cast<CSmArenaClient@>(App.CurrentPlayground);
    if (
        Playground is null
        || Playground.Arena is null
        || Playground.Arena.Resources is null
        || Playground.Arena.Resources.m_AllGameItemModels.Length == 0
    )
        return VehicleType::CarSport;

    const uint index = Dev::GetOffsetUint8(State, vehicleTypeOffset);

    if (index < Playground.Arena.Resources.m_AllGameItemModels.Length) {
        CGameItemModel@ Model = Playground.Arena.Resources.m_AllGameItemModels[index];
        if (Model is null)
            return VehicleType::CarSport;

        if (Model.Id.Value == 0x4000625B)
            return VehicleType::CharacterPilot;

        // if (Model.Name == "CarSport")
        if (Model.Id.Value == 0x40004C95)
            return VehicleType::CarSport;

        // if (Model.Name == "CarSnow")
        if (Model.Id.Value == 0x400016D9)
            return VehicleType::CarSnow;

        // if (Model.Name == "CarRally")
        if (Model.Id.Value == 0x40003CE4)
            return VehicleType::CarRally;

        // if (Model.Name == "CarDesert")
        //     return 3;

        return VehicleType::CarSport;
    }

    return VehicleType::CarSport;
}

// void CheckModels() {
//     if (CarSport is null)
//         UI::Text("CarSport null");
//     else {
//         UI::Text("refs: " + Reflection::GetRefCount(CarSport));
//         UI::Text("pointer: " + Dev_GetPointerForNod(CarSport));
//         if (UI::Button("Explore CarSport"))
//             ExploreNod(CarSport);
//         UI::NodTree(CarSport);
//     }

//     if (CarSnow is null)
//         UI::Text("CarSnow null");
//     else {
//         UI::Text("refs: " + Reflection::GetRefCount(CarSnow));
//         UI::Text("pointer: " + Dev_GetPointerForNod(CarSnow));
//         if (UI::Button("Explore CarSnow"))
//             ExploreNod(CarSnow);
//         UI::NodTree(CarSnow);
//     }

//     if (CarRally is null)
//         UI::Text("CarRally null");
//     else {
//         UI::Text("refs: " + Reflection::GetRefCount(CarRally));
//         UI::Text("pointer: " + Dev_GetPointerForNod(CarRally));
//         if (UI::Button("Explore CarRally"))
//             ExploreNod(CarRally);
//         UI::NodTree(CarRally);
//     }

//     if (CharacterPilot is null)
//         UI::Text("CharacterPilot null");
//     else {
//         UI::Text("refs: " + Reflection::GetRefCount(CharacterPilot));
//         UI::Text("pointer: " + Dev_GetPointerForNod(CharacterPilot));
//         if (UI::Button("Explore CharacterPilot"))
//             ExploreNod(CharacterPilot);
//         UI::NodTree(CharacterPilot);
//     }
// }

// void RemoveModelRefs() {
//     print("removing model refs");

//     if (CarSport !is null) {
//         CarSport.MwRelease();
//         @CarSport = null;
//     }

//     if (CarSnow !is null) {
//         CarSnow.MwRelease();
//         @CarSnow = null;
//     }

//     if (CarRally !is null) {
//         CarRally.MwRelease();
//         @CarRally = null;
//     }

//     if (CharacterPilot !is null) {
//         CharacterPilot.MwRelease();
//         @CharacterPilot = null;
//     }
// }
