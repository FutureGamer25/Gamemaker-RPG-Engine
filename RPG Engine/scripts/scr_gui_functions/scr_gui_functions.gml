//make draw events behave like draw gui events

function draw_set_gui() {
	static oldWidth = 1;
	static oldHeight = 1;
	static cam = camera_create_view(0, 0, 1, 1);
	
	var newWidth = display_get_gui_width();
	var newHeight = display_get_gui_height();
	if (oldWidth != newWidth || oldHeight != newHeight) {
		camera_set_view_size(cam, newWidth, newHeight);
		oldWidth = newWidth;
		oldHeight = newHeight;
	}
	
	camera_apply(cam);
}

function draw_reset_gui() {
	camera_apply(camera_get_active());
}