function slerp_to_2d(valX, valY, destX, destY, spd) {
    var disX = valX - destX;
    var disY = valY - destY;
	var dis = sqrt(disX*disX + disY*disY);
    var che = sqrt(dis) - spd;
    if (che <= 0) {
		return {x : destX, y : destY};
	}
	var mult = (che*che) / dis;
	return {
		x : destX + disX * mult,
		y : destY + disY * mult
	};
}