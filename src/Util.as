int2 Vec2ToInt2(vec2 v) {
    return int2(int(v.x), int(v.y));
}

vec2 Int2ToVec2(int2 v) {
    return vec2(float(v.x), float(v.y));
}
