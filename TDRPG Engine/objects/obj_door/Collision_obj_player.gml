//feather disable once all
if (!room_exists(new_room)) exit;

if (!changeRoom) {
	playerDirX = char_sprite_get_x(obj_player.charSprite);
	playerDirY = char_sprite_get_y(obj_player.charSprite);
	
	set_pause(true);
	changeRoom = true;
	persistent = true;
	room_fade(new_room, fade_color);
}