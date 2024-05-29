/*
c 2023-10-05
m 2023-10-05
*/

const string Core = "NadeoServices";
const string Live = "NadeoLiveServices";

[Setting hidden]
bool enabled = false;

string       accountId;
string       accountName;
// Json::Value@ accountZone;

void Main() {
    NadeoServices::AddAudience(Core);
}

void RenderMenu() {
    if (UI::MenuItem("get-name", "", enabled))
        enabled = !enabled;
}

void Render() {
    if (!enabled) return;

    UI::Begin("get-name", enabled, UI::WindowFlags::None);
        accountId = UI::InputText("accountId", accountId);
        if (UI::Button("get name"))
            startnew(CoroutineFunc(GetNameCoro));
        UI::Text("name:" + accountName);
        if (UI::Button("get zone"))
            startnew(CoroutineFunc(GetZoneCoro));
    UI::End();
}

void GetNameCoro() {
    auto now = Time::Now;
    accountName = NadeoServices::GetDisplayNameAsync(accountId);
    print("name:" + accountName);
    print("getting name took " + (Time::Now - now) + "ms");
}

void GetZoneCoro() {
    while (!NadeoServices::IsAuthenticated(Core)) yield();
    auto now = Time::Now;
    auto req = NadeoServices::Get(
        Core,
        "/accounts/zones/?accountIdList=" + accountId
    );
    req.Start();
    while (!req.Finished()) yield();

    print("zone response:" + req.String());
}
