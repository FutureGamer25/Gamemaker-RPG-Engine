function room_fade(index, color = c_black, seconds = 0.4, out_seconds = seconds) {
	with obj_room_fade {
		if fadeIn return noone;
	}
	var inst = instance_create_depth(0, 0, 0, obj_room_fade);
	inst.color = color;
	inst.fadeSpeed = 1 / (seconds * game_get_speed(gamespeed_fps));
	inst.newRoom = index;
	return inst;
}