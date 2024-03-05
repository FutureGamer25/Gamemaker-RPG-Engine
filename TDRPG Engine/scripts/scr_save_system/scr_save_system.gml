#region key functions
function save_key(key, value) {
	static saveData = __save_get_data();
	saveData.data.general[$ key] = value;
}

function load_key(key, _default) {
	static saveData = __save_get_data();
	return saveData.data.general[$ key] ?? _default;
}

function save_key_room(key, value) {
	static saveData = __save_get_data();
	var roomName = room_get_name(room);
	var rm = saveData.data.rooms[$ roomName];
	if is_undefined(rm) {
		rm = {};
		saveData.data.rooms[$ roomName] = rm;
	}
	rm[$ key] = value;
}

function load_key_room(key, _default) {
	static saveData = __save_get_data();
	var roomName = room_get_name(room);
	var rm = saveData.data.rooms[$ roomName];
	if is_undefined(rm) return _default;
	return rm[$ key] ?? _default;
}

function save_key_static(key, value) {
	var saveData = __save_get_data();
	saveData.dataStatic[$ key] = value;
	save_json(saveData.fileStatic, saveData.dataStatic);
}

function load_key_static(key, _default) {
	static saveData = __save_get_data();
	return saveData.dataStatic[$ key] ?? _default;
}

function save_key_global(key, value) {
	var saveData = __save_get_data();
	saveData.dataGlobal[$ key] = value;
	save_json(saveData.fileGlobal, saveData.dataGlobal);
}

function load_key_global(key, _default) {
	static saveData = __save_get_data();
	return saveData.dataGlobal[$ key] ?? _default;
}
#endregion

#region misc functions
function save_set_slot(slot_index) {
	var saveData = __save_get_data();
	saveData.slot = slot_index;
	var file = save_slot_get_fnames(slot_index);
	saveData.file = file[0];
	saveData.fileStatic = file[1];
}

function save_get_slot() {
	return __save_get_data().slot;
}

function save_slot_exists(slot_index) {
	var file = save_slot_get_fnames(slot_index);
	return (file_exists(file[0]) || file_exists(file[1]));
}

function save_slot_delete(slot_index) {
	var file = save_slot_get_fnames(slot_index);
	if (file_exists(file[0])) {
		file_delete(file[0]);
	}
	if (file_exists(file[1])) {
		file_delete(file[1]);
	}
}

function save_slot_get_fnames(slot_index) {
	var str = string(slot_index);
	return ["save_" + str, "save_static_" + str];
}

function load_slot_temp_start(slot_index) {
	var saveData = __save_get_data();
	saveData.tempSlot = save_get_slot();
	saveData.tempData = saveData.data;
	saveData.tempDataStatic = saveData.dataStatic;
	save_set_slot(slot_index);
	load_all_data();
}

function load_slot_temp_end() {
	var saveData = __save_get_data();
	save_set_slot(saveData.tempSlot);
	saveData.data = saveData.tempData;
	saveData.dataStatic = saveData.tempDataStatic;
}

function save_reset_keys() {
	var saveData = __save_get_data();
	saveData.data = {
		general : {},
		rooms : {}
	};
	saveData.dataStatic = {};
}
#endregion

#region game data
function save_all_data() {
	var saveData = __save_get_data();
	save_json(saveData.file, saveData.data);
	
	if (struct_names_count(saveData.dataStatic) > 0 || file_exists(saveData.fileStatic)) {
		save_json(saveData.fileStatic, saveData.dataStatic);
	}
}

function load_all_data() {
	var saveData = __save_get_data();
	save_reset_keys();
	
	var data = load_json(saveData.file);
	if (!is_undefined(data)) saveData.data = data;
	
	var dataStatic = load_json(saveData.fileStatic);
	if (!is_undefined(dataStatic)) saveData.dataStatic = dataStatic;
}
#endregion

#region json
function save_json(file_name, struct_or_array) {
	var json = json_stringify(struct_or_array);
	var file = file_text_open_write(file_name);
	file_text_write_string(file, json);
	file_text_close(file);
}

function load_json(file_name) {
	if (!file_exists(file_name)) return undefined;
	var file = file_text_open_read(file_name);
	var json = file_text_read_string(file);
	file_text_close(file);
	if (json = "") return undefined;
	return json_parse(json);
}
#endregion

#region init
function __save_get_data() {
	static saveData = {
		slot: 0,
		data: {},
		dataStatic: {},
		dataGlobal: {},
		file: "",
		fileStatic: "",
		fileGlobal: "save_global",
		
		tempSlot: 0,
		tempData: {},
		tempDataStatic: {},
	};
	return saveData;
}

var saveData = __save_get_data();
saveData.dataGlobal = load_json(saveData.fileGlobal) ?? {};
save_set_slot(0);
save_reset_keys();
#endregion