#region internal
function __sound_get_data_struct() {
	static data = {
		group: {},
		category: {},
		defaultCategory: "__default__"
	}
	return data;
}

function __sound_get_category_data(category) {
	static catTable = __sound_get_data_struct().category;
	var data = catTable[$ category];
	if (data = undefined) {
		data = {
			emitter: audio_emitter_create(),
			bus: audio_bus_create(),
			priority: 0,
			gain: 1,
			group: "",
			groupGain: 1,
		}
		audio_emitter_bus(data.emitter, data.bus);
		catTable[$ category] = data;
	}
	return data;
}

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
		catStruct.bus.gain = catStruct.gain * gain;
	}
}

function sound_category_group_get_gain(group) {
	return __sound_get_category_group_data(group).gain;
}
#endregion

#region categories
function sound_category_set_default(category) {
	__sound_get_data_struct().defaultCategory = category;
}

function sound_category_get_default() {
	return __sound_get_data_struct().defaultCategory;
}

function sound_category_priority(category, priority) {
	__sound_get_category_data(category).priority = priority;
}

function sound_category_get_priority(category) {
	return __sound_get_category_data(category).priority;
}

function sound_category_gain(category, gain) {
	var catStruct = __sound_get_category_data(category);
	catStruct.gain = gain;
	catStruct.bus.gain = gain * catStruct.groupGain;
}

function sound_category_get_gain(category) {
	return __sound_get_category_data(category).gain;
}

function sound_category_pitch(category, pitch) {
	audio_emitter_pitch(__sound_get_category_data(category).emitter, pitch);
}

function sound_category_get_pitch(category) {
	return audio_emitter_get_pitch(__sound_get_category_data(category).emitter);
}

function sound_category_set_listener_mask(category, mask) {
	audio_emitter_set_listener_mask(__sound_get_category_data(category).emitter, mask);
}

function sound_category_get_listener_mask(category) {
	return audio_emitter_get_listener_mask(__sound_get_category_data(category).emitter);
}
#endregion

#region sounds
function sound_play(soundid, loops, category = sound_category_get_default(), gain = 1, offset = 0, pitch = 1) {
	var catStruct = __sound_get_category_data(category);
	audio_play_sound_on(catStruct.emitter, soundid, loops, catStruct.priority, gain, offset, pitch);
}

function sound_play_fade(soundid, loops, fade_time, category = sound_category_get_default(), gain = 1, offset = 0, pitch = 1) {
	var catStruct = __sound_get_category_data(category);
	var audio = audio_play_sound_on(catStruct.emitter, soundid, loops, catStruct.priority, gain, offset, pitch);
	return {
		audio: audio,
	}
	
}

function sound_get_audio(sound) {
	return sound.audio;
}

function sound_gain_fade(sound, gain, seconds, end_method = undefined) {
	audio_sound_gain(sound.audio, gain, seconds * 1000);
}
#endregion

#region music
function music_play(soundid) {
	
}

function music_stop() {
	
}

function music_variate() {
	
}
#endregion