randomize();
global.dt = 1 / game_get_speed(gamespeed_fps);

#region window
//remember to set the size of rm_init to the scaled dimensions
//otherwise the screen may look weird for a second
global.view_width = 320;
global.view_height = 240;
global.view_scale = 2;
game_set_resolution(global.view_width, global.view_height, global.view_scale);
#endregion

lang_set_newline("\\n");
lang_set_directory("english");
lang_file_load("object_interactions.txt");

#region overworld sprite maps
var map = char_map_create();
global.charMapPlayer = map;
char_map_default(map, "stand");
char_map_4dir(map, "stand", spr_player_up, spr_player_down, spr_player_left, spr_player_right);
char_map_4dir(map, "walk", spr_player_walk_up, spr_player_walk_down, spr_player_walk_left, spr_player_walk_right);
#endregion

#region dialog and text stuff
global.fontStruct = {
	"normal" : global.fontLarge,
	"arial" : font_arial
}

global.colorStruct = {
	"white" : c_white,
	"black" : c_black,
	"red" : c_red,
	"blue" : c_blue,
	"green" : c_lime
}

global.soundStruct = {
	"sans" : snd_dialog_sans,
	"harsh" : snd_dialog_harsh
}

text_set_color_struct(global.colorStruct);
text_set_font_struct(global.fontStruct);
text_set_sound_struct(global.soundStruct);
text_set_silent_chars(" /n/t");
text_set_gain(0.5);

dialog_character("jeff", sprite_2, sprite_0, snd_dialog_sans, {
	happy : sprite_1,
	happy_talk : sprite_0,
	normal : sprite_2,
	normal_talk : sprite_0,
});
#endregion

depth_sort_set_layer("depth");
instance_create_depth(0, 0, 0, obj_game);

room_goto_next();