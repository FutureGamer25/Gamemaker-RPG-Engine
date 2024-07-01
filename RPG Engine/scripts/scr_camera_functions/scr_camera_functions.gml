function camera_setup_view(view, width, height) {
	var cam = camera_create_view(0, 0, width, height);
	view_enabled = true;
	view_visible[view] = true;
	view_camera[view] = cam;
	return cam;
}

function camera_pos_center(camera, _x, _y, clamp_to_room = false) {
	var w = camera_get_view_width(camera);
	var h = camera_get_view_height(camera);
	_x -= w * 0.5;
	_y -= h * 0.5;
	
	if clamp_to_room {
		_x = clamp(_x, 0, room_width - w);
		_y = clamp(_y, 0, room_height - h);
	}
	
	camera_set_view_pos(camera, _x, _y);
}

function camera_pos_object(camera, object, clamp_to_room = false) {
	if instance_exists(object) {
		camera_pos_center(camera, object.x, object.y, clamp_to_room);
	}
}

function camera_get_x_center(camera) {
	return camera_get_view_x(camera) + camera_get_view_width(camera) * 0.5;
}

function camera_get_y_center(camera) {
	return camera_get_view_y(camera) + camera_get_view_height(camera) * 0.5;
}

