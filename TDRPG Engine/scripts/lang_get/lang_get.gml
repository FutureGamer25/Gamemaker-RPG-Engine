function lang_get(key) {
	static textMap = __lang_get_data().text;
	var text = ds_map_find_value(textMap, key);
	
	if is_undefined(text) {
		if (string_copy(key, 1, 5) = "[raw]") {
			return string_delete(key, 1, 5);
		}
		return "Key not found with name \"" + key + "\".";
	};
	if (array_length(text) <= 0) return "No text in key \"" + key + "\".";
	
	return text[0];
}