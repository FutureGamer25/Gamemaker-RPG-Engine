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

// init stuff

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