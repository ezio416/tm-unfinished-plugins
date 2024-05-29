// c 2024-01-01
// m 2024-01-01

string PosNegColor(bool b) {
    return b ? "\\$0F0true" : "\\$F00false";
}

string PosNegColor(float f) {
    if (f > 0)
        return "\\$0F0" + f;

    if (f < 0)
        return "\\$F00" + Math::Abs(f);

    return "\\$G0";
}
