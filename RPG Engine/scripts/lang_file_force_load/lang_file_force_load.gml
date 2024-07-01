function lang_file_force_load(name) {
	lang_file_unload(name);
	lang_file_load(name);
}