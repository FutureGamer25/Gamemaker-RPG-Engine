//Feather ignore all

///@ignore
function __interact_get_type_data(_type) {
	static _types = {};
	
	var _data = _types[$ _type];
	if (_data = undefined) {
		_data = {
			_interact_array : [],
			_inst_array : []
		};
		_types[$ _type] = _data;
	}
	return _data;
}

///@ignore
function __interaction_class(__inst, __method, __event, __type) constructor {
	static _destroy = function() {
		var _data = __interact_get_type_data(_type);
		var _index = array_get_index(_data._interact_array, self);
		if (_index = -1) return;
		array_delete(_data._interact_array, _index, 1);
		array_delete(_data._inst_array, _index, 1);
	};
	
	static _interact = function() {
		if (is_method(_method)) {
			_method();
		} else if (is_real(_event)) {
			var _ev = _event;
			with (_inst) event_user(_ev);
		}
	};
	
	_type = __type;
	_inst = __inst;
	_method = __method;
	_event = __event;
	
	var _data = __interact_get_type_data(_type);
	array_push(_data._interact_array, self);
	array_push(_data._inst_array, _inst);
}

///@param {Id.Instance} inst
///@param {Function} interact_method
///@param {String} [type]
///@return {Struct.__interaction_class}
function interaction_create(_inst, _interact_method, _type = "__default__") {
	return new __interaction_class(_inst, _interact_method, undefined, _type);
}

///@param {Id.Instance} inst
///@param {Real} event_numb
///@param {String} [type]
///@return {Struct.__interaction_class}
function interaction_create_user_event(_inst, _event_numb, _type = "__default__") {
	return new __interaction_class(_inst, undefined, _event_numb, _type);
}

///@param {Struct.__interaction_class} interaction
function interaction_destroy(_interaction) {
	_interaction._destroy();
}

///@param {Struct.__interaction_class} interaction
///@param {Function} method
function interaction_set_method(_interaction, _method) {
	_interaction._method = _method;
	_interaction._event = undefined;
}

///@param {Struct.__interaction_class} interaction
///@param {Real} event_numb
function interaction_set_user_event(_interaction, _event_numb) {
	_interaction._method = undefined;
	_interaction._event = _event_numb;
}

///@param {String} [type]
///@return {Array<Id.Instance>}
function interact_get_instances(_type = "__default__") {
	var _inst_array = __interact_get_type_data(_type)._inst_array;
	var _len = array_length(_inst_array);
	var _arr = array_create(_len);
	array_copy(_arr, 0, _inst_array, 0, _len);
	return _arr;
}

///@param {Id.Instance} inst
///@param {String} [type]
function interact_instance(_inst, _type = "__default__") {
	var _data = __interact_get_type_data(_type);
	var _index = array_get_index(_data._inst_array, _inst);
	if (_index = -1) return;
	_data._interact_array[_index]._interact();
}

///@param {Real} x
///@param {Real} y
///@param {Bool} [allow_multiple]
///@param {String} [type]
function interact_instance_place(_x, _y, _allow_multiple = false, _type = "__default__") {
	var _data = __interact_get_type_data(_type);
	var _len = array_length(_data._inst_array);
	
	for (var i=0; i<_len; i++) {
		var _inst = _data._inst_array[i];
		if (place_meeting(_x, _y, _inst)) {
			_data._interact_array[i]._interact();
			if (!_allow_multiple) return;
		}
	}
}

///@param {Real} x1
///@param {Real} y1
///@param {Real} x2
///@param {Real} y2
///@param {Bool} [allow_multiple]
///@param {String} [type]
function interact_rectangle(_x1, _y1, _x2, _y2, _allow_multiple = false, _type = "__default__") {
	var _data = __interact_get_type_data(_type);
	var _len = array_length(_data._inst_array);
	
	for (var i=0; i<_len; i++) {
		var _inst = _data._inst_array[i];
		if (collision_rectangle(_x1, _y1, _x2, _y2, _inst, true, true) != noone) {
			_data._interact_array[i]._interact();
			if (!_allow_multiple) return;
		}
	}
}

///@param {Real} x
///@param {Real} y
///@param {Bool} [allow_multiple]
///@param {String} [type]
function interact_point(_x, _y, _allow_multiple = false, _type = "__default__") {
	var _data = __interact_get_type_data(_type);
	var _len = array_length(_data._inst_array);
	
	for (var i=0; i<_len; i++) {
		var _inst = _data._inst_array[i];
		if (collision_point(_x, _y, _inst, true, true) != noone) {
			_data._interact_array[i]._interact();
			if (!_allow_multiple) return;
		}
	}
}