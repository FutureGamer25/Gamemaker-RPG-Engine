///@ignore
function __get_pause_data_struct() {
	static data = {
		array: [], //array of active types
		table: {} //look up struct of types (true if active)
	}
	return data;
}

///@param {String|Array<string>} type_or_array
function get_pause(type_or_array = "") {
	static activeTable = __get_pause_data_struct().table;
	static activeArray = __get_pause_data_struct().array;
	
	if (type_or_array = "") return (array_length(activeArray) > 0);
	if is_array(type_or_array) {
		for (var i=0; i<array_length(type_or_array); i++) {
			if (activeTable[$ type_or_array[i]]) return true;
		}
	} else {
		if (activeTable[$ type_or_array]) return true;
	}
	return false;
}

///@param {String|Array<string>} type_or_array
function get_pause_ignore(type_or_array) {
	static activeTable = __get_pause_data_struct().table;
	static activeArray = __get_pause_data_struct().array;
	
	var activeLen = array_length(activeArray);
	if (activeLen = 0) return false;
	
	if is_array(type_or_array) {
		var ignoreLen = array_length(type_or_array);
		if (activeLen > ignoreLen) return true;
		for (var i=0; i<activeLen; i++) {
			var activeType = activeArray[i];
			var canPause = true;
			for (var j=0; j<ignoreLen; j++) {
				if (activeType = type_or_array[j]) {
					canPause = false;
					break;
				}
			}
			if canPause return true;
		}
		return false;
	} else {
		if (activeLen > 1) return true;
		if (activeTable[$ type_or_array]) return false;
		return true;
	}
}

///@param {Bool} enable
///@param {String} type
function set_pause(enable, type = "__general__") {
	static func = function() {
		static activeTable = __get_pause_data_struct().table;
		static activeArray = __get_pause_data_struct().array;
		
		if (enable = (activeTable[$ type] = true)) return;
		if enable {
			activeTable[$ type] = true;
			array_push(activeArray, type);
		} else {
			struct_remove(activeTable, type);
			array_delete(activeArray, array_get_index(activeArray, type), 1);
		}
	}
	
	var struct = {enable, type};
	var callback = method(struct, func);
	call_later(1, time_source_units_frames, callback);
}