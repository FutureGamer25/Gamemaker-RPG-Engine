function game_get_max_scale(width, height, allow_decimal = false) {
	var scl = min(display_get_width() / width, display_get_height() / height);
	return allow_decimal ? scl : floor(scl);
}