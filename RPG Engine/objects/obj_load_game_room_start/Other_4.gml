if instance_exists(obj_player) {
	obj_player.x = load_key("player_x", obj_player.x);
	obj_player.y = load_key("player_y", obj_player.y);
}

instance_destroy();