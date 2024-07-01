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