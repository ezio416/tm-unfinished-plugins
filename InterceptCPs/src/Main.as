// c 2024-03-08
// m 2024-03-08

bool intercepting = false;

void OnDestroyed() { ResetIntercept(); }
void OnDisabled() { ResetIntercept(); }

void Main() {
    while (true) {
        const bool inMap = GetApp().CurrentPlayground !is null;

        if (!intercepting && inMap)
            Intercept();
        else if (intercepting && !inMap)
            ResetIntercept();

        yield();
    }
}

void Intercept() {
    if (intercepting) {
        warn("Intercept called, but it's already running!");
        return;
    }

    if (GetApp().CurrentPlayground is null)
        return;

    trace("Intercept starting for \"LayerCustomEvent\"");

    try {
        Dev::InterceptProc("CGameManiaApp", "LayerCustomEvent", _Intercept);
        intercepting = true;
    } catch {
        warn("Intercept error: " + getExceptionInfo());
    }
}

void ResetIntercept() {
    if (!intercepting) {
        // warn("ResetIntercept called, but Intercept isn't running!");
        return;
    }

    trace("Intercept ending for \"LayerCustomEvent\"");

    try {
        Dev::ResetInterceptProc("CGameManiaApp", "LayerCustomEvent");
        intercepting = false;
    } catch {
        warn("ResetIntercept error: " + getExceptionInfo());
    }
}

bool _Intercept(CMwStack &in stack, CMwNod@ nod) {
    try {
        CaptureEvent(stack.CurrentWString(1), stack.CurrentBufferWString());
    } catch {
        warn("Exception in Intercept: " + getExceptionInfo());
    }

    return true;
}

void CaptureEvent(const string &in type, MwFastBuffer<wstring> &in data) {
    if (type != "TMGame_RaceCheckpoint_Waypoint")
        return;

    print("=================================================================");

    // for (uint i = 0; i < data.Length; i++)
    //     print("data[" + i + "]: " + data[i]);

    const uint cpTime = Text::ParseUInt(data[0]);
    const uint totalCps = Text::ParseUInt(data[6]);

    print("cp " + totalCps + ": " + Time::Format(cpTime));
}
