function lang_set_directory(name = "") {
	var langData = __lang_get_data();
	var dir = working_directory + name;
	if (string_char_at(dir, string_length(dir)) != "\\") {
		dir += "\\";
	}
	
	if (!directory_exists(dir)) {
		show_message("Language directory \""+name+"\" does not exist.");
		return;
	}
	
	langData.directory = dir;
	langData.directoryName = name;
	var keys = ds_map_keys_to_array(langData.files);
	
	for (var i=0; i<array_length(keys); i++) {
		lang_file_force_load(keys[i]);
	}
}

function lang_file_load(name) {
	var langData = __lang_get_data();
	if (ds_map_exists(langData.files, name)) return;
	
	var keyArr = [];
	var key = undefined;
	var pages;
	ds_map_add(langData.files, name, keyArr);
	var newlineStr = langData.newlineStr;
	var textMap = langData.text;
	
	var dir = langData.directory + name;
	
	if (!file_exists(dir)) {
		show_message("Language file \""+name+"\" does not exist in directory \""
			+langData.directoryName+"\".");
		return;
	}
	
	var file = file_text_open_read(dir);
	
	while (!file_text_eof(file)) {
	    var line = file_text_read_string(file);
		file_text_readln(file);
		line = string_trim_start(line);
		var char = string_char_at(line, 1);
		
		if (char = "[") { //keys and commands
			var endPos = string_pos_ext("]", line, 3);
			if (endPos > 2) { //get key
				key = string_copy(line, 2, endPos - 2);
				pages = [];
				array_push(keyArr, key);
				ds_map_set(textMap, key, pages);
				
				line = string_trim_start(string_delete(line, 1, endPos));
				char = string_char_at(line, 1);
			} else { //get lang commands
				#region split string
				if (endPos != 2) continue;
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
				continue;
			}
		}
		
		if (is_undefined(key)) continue;
		
		if (char = "\"") { //quoted text
			var endPos = string_last_pos("\"", line);
			if (endPos = 0) endPos = string_length(line);
			line = string_copy(line, 2, endPos - 2);
		} else { //non-quoted text
			var comment = string_pos("//", line);
			if (comment != 0) {
				line = string_copy(line, 1, comment - 1);
			}
			
			line = string_trim_end(line);
			if (line = "") continue;
		}
		
		line = string_replace_all(line, newlineStr, "\n");
		array_push(pages, line);
	}
	
	file_text_close(file);
}

function lang_file_unload(name) {
	var langData = __lang_get_data();
	var key_arr = ds_map_find_value(langData.files, name);
	if is_undefined(key_arr) return; // file isn't loaded
	var keys = array_length(key_arr);
	var textMap = langData.text;
	
	for (var i=0; i<keys; i++) {
	    ds_map_delete(textMap, key_arr[i]);
	}
	
	ds_map_delete(langData.files, name);
}

function lang_file_force_load(name) {
	lang_file_unload(name);
	lang_file_load(name);
}

function lang_get(key) {
	static textMap = __lang_get_data().text;
	var text = ds_map_find_value(textMap, key);
	
	if is_undefined(text) {
		if (!is_string(key)) return "Key must be a string.";
		if (string_copy(key, 1, 5) = "[raw]") {
			return string_delete(key, 1, 5);
		}
		return "Key not found with name \"" + key + "\".";
	};
	if (array_length(text) <= 0) return "No text in key \"" + key + "\".";
	
	return text[0];
}

function lang_get_array(key) {
	static textMap = __lang_get_data().text;
	var text = ds_map_find_value(textMap, key);
	
	if is_undefined(text) {
		if (!is_string(key)) return ["Key must be a string."];
		if (string_copy(key, 1, 5) = "[raw]") {
			return [string_delete(key, 1, 5)];
		}
		return ["Key not found with name \"" + key + "\"."];
	};
	if (array_length(text) <= 0) return ["No text in key \"" + key + "\"."];
	
	return text;
}

function lang_set_newline(str) {
	__lang_get_data().newlineStr = str;
}

#region internal
///@ignore
function __lang_get_data() {
	static data = {
		directory: working_directory,
		directoryName: "",
		newlineStr: "\\n",
		text: ds_map_create(),
		files: ds_map_create(),
	};
	return data;
}
#endregion