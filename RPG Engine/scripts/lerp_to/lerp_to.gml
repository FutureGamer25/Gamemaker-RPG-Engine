function lerp_to(val, dest, spd) {
	var dis = val - dest;
	return dest + sign(dis) * max(0, abs(dis) - spd);
}