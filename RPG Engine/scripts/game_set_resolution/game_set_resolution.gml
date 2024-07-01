function game_set_resolution(width, height, scale = 1) {
	window_set_size(width * scale, height * scale);
	window_center();
	surface_resize(application_surface, width * scale, height * scale);
	display_set_gui_size(width, height);
}