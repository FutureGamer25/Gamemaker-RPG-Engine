#region directory
function lang_set_directory(name = "") {
	var langData = __lang_get_data();
	var dir = working_directory + name;
	if (string_char_at(dir, string_length(dir)) != "\\") {
		dir += "\\";
	}
	
	if (!directory_exists(dir)) {
		show_debug_message($"LANG: Language directory \"{name}\" does not exist.");
		return;
	}
	
	langData.directory = dir;
	langData.directoryName = name;
	var keys = struct_get_names(langData.textFiles);
	
	for (var i=0; i<array_length(keys); i++) {
		lang_file_force_load(keys[i]);
	}
}

function lang_get_directory() {
	return __lang_get_data().directoryName;
}
#endregion

#region load lang files
function lang_file_load(fname) {
	var langData = __lang_get_data();
	if (langData.textFiles[$ fname] != undefined) return;
	
	var keyArr = [];
	var key = undefined;
	var pages;
	langData.textFiles[$ fname] = keyArr;
	var newlineStr = langData.newlineStr;
	var textMap = langData.text;
	
	var dir = langData.directory + fname;
	
	if (!file_exists(dir)) {
		show_debug_message($"LANG: Language file \"{fname}\" does not exist in directory \"{langData.directoryName}\".");
		return;
	}
	
	var file = file_text_open_read(dir);
	
	while (!file_text_eof(file)) {
		var line = string_trim_start(file_text_read_string(file));
		var char = string_char_at(line, 1);
		file_text_readln(file);
		
		while (char = "[") { //keys and commands
			var endPos = string_pos_ext("]", line, 3);
			if (endPos > 2) { //get key
				key = string_copy(line, 2, endPos - 2);
				pages = [];
				array_push(keyArr, key);
				ds_map_set(textMap, key, pages);
				
				line = string_trim_start(string_delete(line, 1, endPos));
				char = string_char_at(line, 1);
			} else { //get command
				line = "";
				char = "";
				
				#region split string
				if (endPos < 2) break;
				line = string_trim(string_delete(line, 1, 2));
				var arr = string_split_ext(line, [" ", "\t"], false, 1);
				var command = arr[0];
				var param = "";
				if (array_length(arr) > 1) param = string_trim_start(arr[1]);
				#endregion
				
				#region run command
				switch (command) {
				case "newline":
					newlineStr = param;
					break;
				}
				#endregion
				break;
			}
		}
		
		if (is_undefined(key)) continue;
		
		if (char = "\"") { //quoted text
			var endPos = string_last_pos("\"", line);
			if (endPos < 2) endPos = string_length(line) + 1;
			line = string_copy(line, 2, endPos - 2);
		} else { //non-quoted text
			var comment = string_pos("//", line);
			if (comment != 0) line = string_copy(line, 1, comment - 1);
			
			line = string_trim_end(line);
			if (line = "") continue;
		}
		
		
		line = string_replace_all(line, newlineStr, "\n");
		array_push(pages, line);
	}
	
	file_text_close(file);
}

function lang_file_unload(fname) {
	var langData = __lang_get_data();
	var key_arr = langData.textFiles[$ fname];
	if is_undefined(key_arr) return; // file isn't loaded
	var keys = array_length(key_arr);
	var textMap = langData.text;
	
	for (var i=0; i<keys; i++) {
	    ds_map_delete(textMap, key_arr[i]);
	}
	
	struct_remove(langData.textFiles, fname);
}

function lang_file_force_load(fname) {
	lang_file_unload(fname);
	lang_file_load(fname);
}
#endregion

#region get text
///@param {String} key
///@return {Any}
function lang_get(key) {
	static textMap = __lang_get_data().text;
	var text = ds_map_find_value(textMap, key);
	
	if is_undefined(text) {
		if (!is_string(key)) return "Key must be a string.";
		if (string_starts_with(key, "[raw]")) {
			return string_delete(key, 1, 5);
		}
		return $"Key not found with name \"{key}\".";
	};
	if (array_length(text) <= 0) return $"No text in key \"{key}\".";
	
	return text[0];
}

///@param {String} key
///@return {Array<String>}
function lang_get_array(key) {
	static textMap = __lang_get_data().text;
	var text = ds_map_find_value(textMap, key);
	
	if is_undefined(text) {
		if (!is_string(key)) return ["Key must be a string."];
		if (string_starts_with(key, "[raw]")) {
			return string_split(string_delete(key, 1, 5), "[page]");
		}
		return [/*funny gap*/$"Key not found with name \"{key}\"."];
	};
	if (array_length(text) <= 0) return [/*funny gap*/$"No text in key \"{key}\"."];
	
	return text;
}
#endregion

#region load sprites
function lang_sprite_load(key, fname, default_sprite = __lang_sprite_default) {
	var langData = __lang_get_data();
	
	langData.spriteFiles[$ fname] = key;
	var sprData = langData.sprite[$ key];
	if (sprData = undefined) {
		sprData = {sprite: default_sprite, file: ""};
		langData.sprite[$ key] = sprData;
	};
	if (sprData.file = fname) return;
	
	langData.sprite[$ key] = default_sprite;
	var dir = langData.directory + fname;
	if (!file_exists(dir)) return;
	
	var spr = sprite_add(
		fname, sprite_get_number(default_sprite), false, false,
		sprite_get_xoffset(default_sprite), sprite_get_yoffset(default_sprite)
	);
	
	langData.sprite[$ key] = {sprite: spr, file: fname};
	
	if (default_sprite != __lang_sprite_default) {
		sprite_collision_mask(
			spr, false, sprite_get_bbox_mode(default_sprite),
			sprite_get_bbox_left(default_sprite), sprite_get_bbox_top(default_sprite),
			sprite_get_bbox_right(default_sprite), sprite_get_bbox_bottom(default_sprite),
			bboxkind_rectangular, 0
		);
	}
}

function lang_sprite_unload(fname) {
	
}
#endregion

#region get sprites and misc
function lang_get_path(fname) {
	return __lang_get_data().directory + fname;
}

function lang_get_sprite(key) {
	langData.sprite[$ key]
}
#endregion

#region lang file settings
function lang_set_newline(str) {
	__lang_get_data().newlineStr = str;
}
#endregion

#region internal
///@ignore
function __lang_get_data() {
	static data = {
		directory: working_directory,
		directoryName: "",
		newlineStr: "\\n",
		textFiles: {},
		text: ds_map_create(),
		spriteFiles: {},
		sprite: {},
	};
	return data;
}
#endregion