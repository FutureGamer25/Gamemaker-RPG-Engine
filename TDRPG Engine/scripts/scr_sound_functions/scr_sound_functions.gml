#region internal
///@ignore
function __sound_get_data_struct() {
	static data = {
		group: {},
		category: {},
		defaultCategory: "__default__"
	}
	return data;
}

///@ignore
function __sound_get_category_data(category, read_only = false) {
	static catTable = __sound_get_data_struct().category;
	static nullData = {
		emitter: -1,
		bus: -1,
		priority: 0,
		gain: 1,
		group: "",
		groupGain: 1,
	};
	
	var data = catTable[$ category];
	if (data = undefined) {
		if (read_only) return nullData;
		data = {
			emitter: audio_emitter_create(),
			bus: audio_bus_create(),
			priority: 0,
			gain: 1,
			group: "",
			groupGain: 1,
		};
		audio_emitter_bus(data.emitter, data.bus);
		catTable[$ category] = data;
	}
	return data;
}

///@ignore
function __sound_get_category_group_data(group) {
	static groupTable = __sound_get_data_struct().group;
	var data = groupTable[$ group];
	if (data = undefined) {
		data = {
			gain: 1,
			category: [],
		}
		groupTable[$ group] = data;
	}
	return data;
}

///@ignore
function __sound_update_category_gain(cat_struct) {
	cat_struct.bus.gain = cat_struct.gain * cat_struct.groupGain;
}
#endregion

#region general
function sound_master_gain(gain) {
	audio_master_gain(gain);
}

function sound_master_get_gain() {
	return audio_get_master_gain(0);
}
#endregion

#region category groups
function sound_category_set_group(category, group) {
	var catStruct = __sound_get_category_data(category);
	if (catStruct.group = group) return;
	
	if (catStruct.group != "") { //remove from old group
		var array = __sound_get_category_group_data(catStruct.group).category;
		array_delete(array, array_get_index(array, category), 1);
	}
	
	catStruct.group = group; //add to new group
	var newGroup = __sound_get_category_group_data(group);
	array_push(newGroup.category, category);
	var gain = newGroup.gain;
	catStruct.groupGain = gain;
	catStruct.bus.gain = catStruct.gain * gain;
}

function sound_category_group_gain(group, gain) {
	var groupStruct = __sound_get_category_group_data(group);
	if (groupStruct.gain = gain) return;
	groupStruct.gain = gain;
	var array = groupStruct.category;
	for (var i=0; i<array_length(array); i++) {
		var catStruct = __sound_get_category_data(array[i]);
		catStruct.groupGain = gain;
		__sound_update_category_gain(catStruct);
	}
}

function sound_category_group_get_gain(group) {
	return __sound_get_category_group_data(group).gain;
}
#endregion

#region categories
function sound_category_set_default(category) {
	static struct = __sound_get_data_struct();
	struct.defaultCategory = category;
}

function sound_category_get_default() {
	static struct = __sound_get_data_struct();
	return struct.defaultCategory;
}

function sound_category_priority(category, priority) {
	__sound_get_category_data(category).priority = priority;
}

function sound_category_get_priority(category) {
	return __sound_get_category_data(category, true).priority;
}

function sound_category_gain(category, gain) {
	var catStruct = __sound_get_category_data(category);
	catStruct.gain = gain;
	__sound_update_category_gain(catStruct);
}

function sound_category_get_gain(category) {
	return __sound_get_category_data(category, true).gain;
}

function sound_category_pitch(category, pitch) {
	audio_emitter_pitch(__sound_get_category_data(category).emitter, pitch);
}

function sound_category_get_pitch(category) {
	var emitter = __sound_get_category_data(category, true).emitter;
	if (emitter = -1) return 1;
	return audio_emitter_get_pitch(emitter);
}

function sound_category_set_listener_mask(category, mask) {
	audio_emitter_set_listener_mask(__sound_get_category_data(category).emitter, mask);
}

function sound_category_get_listener_mask(category) {
	var emitter = __sound_get_category_data(category, true).emitter;
	if (emitter = -1) return audio_get_listener_mask();
	return audio_emitter_get_listener_mask(emitter);
}

function sound_category_push_effect(category, effect) {
	var bus = __sound_get_category_data(category).bus;
	var pos = -1;
	for (var i=array_length(bus.effects)-1; i>=0; i--) {
		if (bus.effects[i] = undefined) {
			pos = i;
		} else if (pos != -1) {
			break;
		}
	}
	if (pos = -1) {
		show_message("Too many effects on sound category \"" + category + "\"");
		return;
	}
	bus.effects[pos] = effect;
}

function sound_category_pop_effect(category) {
	var bus = __sound_get_category_data(category).bus;
	for (var i=array_length(bus.effects)-1; i>=0; i--) {
		var slot = bus.effects[i];
		if (slot != undefined) {
			bus.effects[i] = undefined;
			return slot;
		}
	}
	return undefined;
}

function sound_category_clear_effects(category) {
	var bus = __sound_get_category_data(category).bus;
	for (var i=array_length(bus.effects)-1; i>=0; i--) {
		bus.effects[i] = undefined;
	}
}

function sound_category_get_bus(category) {
	return __sound_get_category_data(category).bus;
}
#endregion

#region sounds
function sound_play(sound, loops, category = undefined, gain = 1, offset = 0, pitch = 1) {
	if (!is_string(category)) category = sound_category_get_default();
	var catStruct = __sound_get_category_data(category);
	return audio_play_sound_on(catStruct.emitter, sound, loops, catStruct.priority, gain, offset, pitch);
}

function sound_stop(index) {
	audio_stop_sound(index);
}

function sound_pause(index) {
	audio_pause_sound(index);
}

function sound_resume(index) {
	audio_resume_sound(index);
}

function sound_gain(index, volume, seconds = 0, callback = undefined, args = undefined) {
	audio_sound_gain(index, volume, seconds * 1000);
	if is_method(callback) {
		if (!is_array(args)) args = [];
		var source = time_source_create(time_source_global, seconds, time_source_units_seconds, callback, args, 1, time_source_expire_after);
		time_source_start(source);
	}
}
#endregion