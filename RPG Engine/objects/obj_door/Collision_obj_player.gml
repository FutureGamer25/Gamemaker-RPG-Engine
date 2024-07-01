//feather disable once all
if (!room_exists(new_room)) exit;

if (!changeRoom) {
	playerAngle = char_sprite_get_angle(obj_player.charSprite);
	
	set_pause(true);
	changeRoom = true;
	persistent = true;
	room_fade(new_room, fade_color);
}