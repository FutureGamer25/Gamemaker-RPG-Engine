function save_game() {
	save_key("room", room_get_name(room));
	if instance_exists(obj_player) {
		save_key("player_x", obj_player.x);
		save_key("player_y", obj_player.y);
	}
	
	save_all_data(); //save keys to disk
}

function load_game() {
	load_all_data(); //load keys from disk
	
	var rm = load_key("room", room_get_name(room));
	room_goto(asset_get_index(rm));
	instance_create_depth(0, 0, 0, obj_load_game_room_start);
}