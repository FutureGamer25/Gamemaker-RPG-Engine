#region internal
///@ignore
function __follower_get_data() {
	static Class = function() constructor {
		getIndex = function(obj) {
			var len = array_length(followers);
			for (var i=0; i<len; i++) {
				var fol = followers[i].instance;
				if (obj = fol) return i;
				if (obj = fol.object_index) return i;
			}
			return -1;
		}
		refreshOffsets = function() {
			endOffset = 0;
			var back = playerDelayBack;
			var len = array_length(followers);
			for (var i=0; i<len; i++) {
				var fol = followers[i];
				endOffset += fol.delayFront + back;
				fol.offset = endOffset;
				back = fol.delayBack;
			}
			historyReserve(endOffset + 1);
		}
		historyReserve = function(size) {
			var oldSize = array_length(history);
			if (size = oldSize) return;
			if (size > oldSize) array_resize(history, size);
			var newIndex =  max(0, historyIndex + size - oldSize);
			array_copy(history, newIndex, history, historyIndex, oldSize - historyIndex);
			historyIndex = newIndex;
			if (size < oldSize) array_resize(history, size);
			if (historyLength > size) historyLength = size;
		}
		historyPushFront = function(data) {
			var reserved = array_length(history);
			if (historyLength < reserved) historyLength ++;
			historyIndex --;
			if (historyIndex < 0) historyIndex += reserved; //fake modulo
			history[historyIndex] = data;
		}
		historyGet = function(index) {
			if (index < 0 || index >= historyLength) return undefined;
			return history[(historyIndex + index) % array_length(history)];
		}
		historySet = function(index, data) {
			if (index < 0 || index >= historyLength) return;
			history[(historyIndex + index) % array_length(history)] = data;
		}
		
		history = [undefined];
		historyIndex = 0;
		historyLength = 0;
		
		defaultDelayFront = 1;
		defaultDelayBack = 0;
		playerDelayBack = 0;
		followers = [];
		maxPosition = -1;
		endOffset = 0;
	}
	static data = new Class();
	return data;
}
#endregion

#region delay
///@param {Real} frames
function follower_set_delay(frames) {
	__follower_get_data().defaultDelayFront = frames;
}

///@param {Real} frames
function follower_set_back_delay(frames) {
	__follower_get_data().defaultDelayBack = frames;
}

///@param {Real} frames
function follower_player_set_back_delay(frames) {
	__follower_get_data().playerDelayBack = frames;
}
#endregion

#region add / remove
///@param {Id.Instance} instance
///@param {Struct} parameters
function follower_add(instance, parameters = {}) {
	static folData = __follower_get_data();
	static frontHash = variable_get_hash("delay");
	static backHash = variable_get_hash("back_delay");
	
	var delFront = struct_get_from_hash(parameters, frontHash) ?? folData.defaultDelayFront;
	var delBack = struct_get_from_hash(parameters, backHash) ?? folData.defaultDelayBack;
	
	var struct = {
		instance: instance,
		delayFront: delFront,
		delayBack: delBack,
		offset: 0,
		position: 0,
		prevPosition: 0,
	}
	array_push(folData.followers, struct);
	folData.refreshOffsets();
	
	var pos = folData.maxPosition - max(0, min(struct.offset, folData.historyLength - 1));
	struct.position = pos;
	struct.prevPosition = pos;
}

///@param {Asset.GMObject} follower_obj
///@param {Id.Instance|Asset.GMObject} player_obj
function follower_create(follower_obj, player_obj = noone) {
	var inst;
	if instance_exists(player_obj) {
		inst = instance_create_layer(player_obj.x, player_obj.y, player_obj.layer, follower_obj);
	} else {
		inst = instance_create_depth(0, 0, 0, follower_obj);
	}
	follower_add(inst);
}

///@param {Id.Instance|Asset.GMObject} obj
///@param {Bool} destroy
function follower_remove(obj, destroy = false) {
	static folData = __follower_get_data();
	follower_remove_index(folData.getIndex(obj), destroy);
}

///@param {Bool} destroy
function follower_remove_all(destroy = false) {
	static folData = __follower_get_data();
	var followers = folData.followers;
	if destroy {
		var len = array_length(followers);
		for (var i=0; i<len; i++) {
			instance_destroy(followers[i].instance);
		}
	}
	array_resize(followers, 0);
	folData.refreshOffsets();
}

///@param {Real} index
///@param {Bool} destroy
function follower_remove_index(index, destroy = false) {
	static folData = __follower_get_data();
	var followers = folData.followers;
	if (index < 0 || index >= array_length(followers)) return;
	if (destroy) instance_destroy(followers[index].instance);
	array_delete(followers, index, 1);
	folData.refreshOffsets();
	
}

///@param {Id.Instance|Asset.GMObject} obj
function follower_destroy(obj) {
	follower_remove(obj, true)
}

function follower_destroy_all() {
	follower_remove_all(true);
}
#endregion

#region followers
///@param {Bool} is_player_moving
///@param {Any} player_data
function follower_update(is_player_moving, player_data) {
	static folData = __follower_get_data();
	
	if (is_player_moving) {
		folData.historyPushFront(player_data);
		folData.maxPosition ++;
	}
	
	var maxPosition = folData.maxPosition;
	var followers = folData.followers;
	var len = array_length(followers);
	for (var i=0; i<len; i++) {
		var fol = followers[i];
		fol.prevPosition = fol.position;
		if ((maxPosition - fol.offset) > fol.position) fol.position ++; //auto move
	}
}

///@param {Id.Instance|Asset.GMObject} obj
///@return {Real}
function follower_get_index(obj = id) {
	static folData = __follower_get_data();
	return folData.getIndex(obj);
}

///@param {Real} index
///@return {Id.Instance}
function follower_get_instance(index) {
	static folData = __follower_get_data();
	if (index < 0 || index >= array_length(folData.followers)) return noone;
	return folData.followers[index].instance;
}

///@param {Id.Instance|Asset.GMObject} obj
///@return {Any}
function follower_get_history(obj = id) {
	return follower_history_get(follower_get_history_pos(obj));
}

///@param {Id.Instance|Asset.GMObject} obj
///@return {Bool}
function follower_has_valid_history(obj = id) {
	return follower_history_get(follower_get_history_pos(obj)) != undefined;
}

///@param {Id.Instance|Asset.GMObject} obj
///@return {Real}
function follower_get_history_pos(obj = id) {
	static folData = __follower_get_data();
	return folData.followers[folData.getIndex(obj)].position;
}

///@param {Id.Instance|Asset.GMObject} obj
///@return {Bool}
function follower_has_moved_history(obj = id) {
	static folData = __follower_get_data();
	var fol = folData.followers[folData.getIndex(obj)];
	return fol.position != fol.prevPosition;
}
#endregion

#region history
function follower_history_clear() {
	static folData = __follower_get_data();
	
	folData.historyLength = 0;
	folData.maxPosition = -1;
	
	var followers = folData.followers;
	var len = array_length(followers);
	for (var i=0; i<len; i++) {
		var fol = followers[i];
		fol.position = -1;
		fol.prevPosition = -1;
	}
}

///@param {Any} data
function follower_history_push(data) {
	static folData = __follower_get_data();
	folData.historyPushFront(data);
}

///@param {Real} position
///@return {Any}
function follower_history_get(position) {
	static folData = __follower_get_data();
	return folData.historyGet(folData.maxPosition - position);
}

///@param {Real} position
///@param {Any} data
function follower_history_set(position, data) {
	static folData = __follower_get_data();
	folData.historySet(folData.maxPosition - position, data);
}

///@return {Real}
function follower_history_min_pos() {
	static folData = __follower_get_data();
	return folData.maxPosition - folData.historyLength + 1;
}

///@return {Real}
function follower_history_max_pos() {
	static folData = __follower_get_data();
	return folData.maxPosition;
}
#endregion