#macro __dialog_box_width 176
#macro __dialog_box_height 56
#macro __dialog_box_sep 16
#macro __dialog_command_prefix "#"

function dialog_start(lang_key, top_of_screen = undefined, pause = true) {
	var inst = dialog_create(lang_get_array(lang_key), top_of_screen);
	inst.check_inputs();
	if pause {
		instance_pause_all();
		inst.set_end_method(function() { instance_unpause_all(); });
	}
	return inst;
}

function dialog_create(str_or_array, top_of_screen = undefined) {
	if is_undefined(top_of_screen) {
		top_of_screen = false;
		if instance_exists(obj_player) {
			var pos = obj_player.y - camera_get_view_y(view_get_camera(0));
			if (pos > (global.view_height / 2 + 16)) top_of_screen = true;
		}
	}
	
	var inst = instance_create_depth(0, 0, 0, obj_dialog);
	__dialog_default_transform(inst, top_of_screen);
	inst.set_text(str_or_array);
	return inst;
}

function __dialog_default_transform(dialog_obj, top_of_screen) {
	var w = __dialog_box_width;
	var h = __dialog_box_height;
	var sep = __dialog_box_sep;
	with dialog_obj {
		x = (global.view_width - w) / 2;
		y = top_of_screen ? sep : (global.view_height - h - sep);
		set_size(w, h);
	}
}

function dialog_func(name, func) {
	global.dialog_data.func[$ name] = func;
}

function dialog_character(char_name, default_face_spr, default_talk_spr = default_face_spr, talk_sound = undefined, face_struct) {
	global.dialog_data.char[$ char_name] = {
		sound : talk_sound,
		face : face_struct,
		defaultFace : default_face_spr,
		defaultTalk : default_talk_spr
	};
}

function dialog_get_command(str) {
	static pre = __dialog_command_prefix;
	static preLen = string_length(pre);
	static empty = [" ", "\t"];
	
	var struct = {command : "", param : ""};
	
	if (string_copy(str, 1, preLen) != pre) return struct;
	str = string_delete(str, 1, preLen);
	
	str = string_trim_start(str, empty);
	var par = string_split_ext(str, empty, false, 1); //spaces and tabs
	var len = array_length(par);
	if (len = 0) return struct;
	
	struct.command = par[0];
	if (len >= 2) struct.param = string_trim_start(par[1], empty);
	return struct;
}

#region init
global.dialog_data = {
	func : {},
	char : {
		none : undefined
	}
}
#endregion