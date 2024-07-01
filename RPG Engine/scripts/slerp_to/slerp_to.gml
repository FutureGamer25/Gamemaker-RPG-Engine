function slerp_to(val, dest, spd) {
    var dis = val - dest;
    var che = sqrt(abs(dis)) - spd;
    if (che <= 0) return dest;
    return dest + sign(dis) * (che*che);
}