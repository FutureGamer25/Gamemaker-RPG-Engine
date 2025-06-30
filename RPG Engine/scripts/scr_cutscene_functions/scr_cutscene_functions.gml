#region cutscenes
function cutscene_begin() {
	var _global = __cutscene_get_global();
	var _script = new __cutscene_script_class();
	var _cutscene = new __cutscene_class(_script);
	_global._script_stack_push(_script);
	_global._cutscene_stack_push(_cutscene);
	return _cutscene;
}

function cutscene_end() {
	var _global = __cutscene_get_global();
	_global._cutscene_current._start();
	_global._script_stack_pop();
	_global._cutscene_stack_pop();
}

function cutscene_start(_cutscene = __cutscene_get_global()._cutscene_current) {
	_cutscene._start();
}

function cutscene_stop(_cutscene = __cutscene_get_global()._cutscene_current) {
	_cutscene._stop();
}

function cutscene_set_speed(_cutscene, _speed) {
	_cutscene._set_speed(_speed);
}

function cutscene_next(_cutscene = __cutscene_get_global()._cutscene_current, _branch_name = "__current__") {
	_cutscene._next(_branch_name);
}
#endregion

#region templates
function cutscene_template_begin() {
	var _global = __cutscene_get_global();
	var _script = new __cutscene_script_class();
	_global._script_stack_push(_script);
	return _script;
}

function cutscene_template_end() {
	var _global = __cutscene_get_global();
	_global._script_stack_pop();
}
#endregion

#region events
function cutscene_add_event(_constructor, _parameter = undefined) {
	static _global = __cutscene_get_global();
	var _script = _global._script_current;
	if (_script = undefined) return;
	array_push(_script._events, new __cutscene_constructor_class(_constructor, _parameter, _global._time_units));
}

function cutscene_add_method(_method, _parameter = undefined) {
	static _global = __cutscene_get_global();
	var _script = _global._script_current;
	if (_script = undefined) return;
	array_push(_script._events, new __cutscene_method_class(_method, _parameter));
}
#endregion



#region internal

#region global
#macro cutscene_time_units_frames 0
#macro cutscene_time_units_seconds 1
#macro cutscene_time_units_seconds_dt 2

#macro cutscene_state_initial 0
#macro cutscene_state_active 1
#macro cutscene_state_paused 2
#macro cutscene_state_stopped 3

function __cutscene_get_global() {
	static _class = function() constructor {
		_script_stack_push = function(_script) {
			array_push(_script_stack, _script);
			_script_current = _script;
		}
		_script_stack_pop = function() {
			array_pop(_script_stack);
			_script_current = array_last(_script_stack);
		}
		
		_cutscene_stack_push = function(_cutscene) {
			array_push(_cutscene_stack, _cutscene);
			_cutscene_current = _cutscene;
		}
		_cutscene_stack_pop = function() {
			array_pop(_cutscene_stack);
			_cutscene_current = array_last(_cutscene_stack);
		}
		
		_script_stack = [];
		_script_current = undefined;
		
		_cutscene_stack = [];
		_cutscene_current = undefined;
		_time_units = cutscene_time_units_frames;
	}
	static _global = new _class();
	return _global;
}
#endregion

#region event types
enum __cutscene_event_type {
	_constructor, _method
}

function __cutscene_constructor_class(_constructor, _parameter, _time_units) constructor {
	static _type = __cutscene_event_type._constructor;
	self._constructor = _constructor;
	self._parameter = _parameter;
	self._time_units = _time_units;
}

function __cutscene_method_class(_method, _parameter) constructor {
	static _type = __cutscene_event_type._method;
	self._method = _method;
	self._parameter = _parameter;
}
#endregion

function __cutscene_class(_script, _branch_name_struct = {}) constructor {
	_automatic_step = true;
	self._script = _script;
	_branch_names = _branch_name_struct;
	_branches = [undefined];
	_active_branch_count = 0;
	_current_branch = undefined;
	_time_source = undefined;
	_state = cutscene_state_initial;
	
	static _global = __cutscene_get_global();
	
	static _enable_time_source = function() {
		if (!_automatic_step || time_source_exists(_time_source)) return;
		var _callback = function() {
			var _stopped = _step();
			if (_stopped) time_source_destroy(_time_source);
		}
		_time_source = time_source_create(time_source_game, 1, time_source_units_frames, _callback, [], -1);
	}
	
	static _start = function() {
		_state = cutscene_state_active;
		array_resize(_branches, 1);
		_branches[0] = new __cutscene_branch_class(self, _script);
		_active_branch_count = 1;
		_enable_time_source();
	}
	
	static _stop = function() {
		_state = cutscene_state_stopped;
		time_source_destroy(_time_source);
	}
	
	static _pause = function() {
		if (_state != cutscene_state_active) return;
		_state = cutscene_state_paused;
		time_source_destroy(_time_source);
	}
	
	static _unpause = function() {
		if (_state != cutscene_state_paused) return;
		_state = cutscene_state_active;
		_enable_time_source();
	}
	
	static _set_speed = function(_speed) {
		_main_branch._speed = _speed;
	}
	
	static _next = function(_branch_name) {
		_activate();
		_get_branch(_branch_name)._next();
	}
	
	static _step = function() {
		if (_state != cutscene_state_active) return (_state = cutscene_state_stopped);
		
		_global._cutscene_stack_push(self);
		for (var _i = array_length(_branches) - 1; _i >= 0; _i--) {
			var _branch = _branches[_i];
			if (!_branch._active) { //clean up inactive branches
				array_delete(_branches, _i);
				continue;
			}
			
			var _ended = _branch._step(1);
			if (_ended) {
				_branch_remove(_branch);
			}
		}
		_global._cutscene_stack_pop();
		
		if (_active_branch_count <= 0) _state = cutscene_state_stopped;
		return (_state = cutscene_state_stopped);
	}
	
	static _get_branch = function(_branch_name) {
		if (_branch_name = "__current__") {
			return _current_branch;
		}
		return _branch_names[$ _branch_name];
	}
	
	static _branch_add(_branch, _name = "") = function {
		//if (_branch._active) return; //not needed atm
		_branch._active = true;
		_active_branch_count++;
		array_push(_branches, _branch);
		if (_name != "" && _branch_names[$ _name] = undefined) {
			_branch_names[$ _name] = _branch;
			_branch._name = _name;
		}
	}
	
	static _branch_remove(_branch) = function {
		//if (!_branch._active) return; //not needed atm
		_branch._active = false;
		_active_branch_count--;
		if (_branch._name != "") {
			struct_remove(_branch_names, _branch._name);
			_branch._name = "";
		}
	}
}

function __cutscene_script_class() constructor {
	_events = [];
	_labels = {};
}

function __cutscene_branch_class(_cutscene, _script) constructor {
	_name = ""; //used by __cutscene_class
	_active = false; //used by __cutscene_class
	
	_ended = false;
	_paused = false;
	_speed = 1;
	
	_callstack_top = {
		_event_index: 0,
		_events: _script._events,
		_labels: _script._labels,
	};
	_callstack = [_callstack_top];
	
	_initialize_event = true;
	_running_event = undefined;
	_live_script = new __cutscene_script_class();
	
	static _global = __cutscene_get_global();
	
	//static _start = function() {
	//	_initialize_event = true;
	//	_callstack_top._event_index = 0;
	//	_running_event = undefined;
	//}
	//
	//static _stop = function() {
	//	_callstack_top._event_index = array_length(_callstack_top._events);
	//}
	
	static _next = function() {
		_initialize_event = true;
		_callstack_top._event_index++;
	}
	
	static _goto = function(_label_name) {
		var _index = _callstack_top._labels[$ _label_name];
		if (_index != undefined) {
			_initialize_event = true;
			_callstack_top._event_index = _index;
			return true;
		}
		
		for (var _i = array_length(_callstack) - 2; _i >= 0; _i--) {
			var _index = _callstack[_i]._labels[$ _label_name];
			if (_index != undefined) {
				_callstack_return_to_index(_i);
				_initialize_event = true;
				_callstack_top._event_index = _index;
				return true;
			}
		}
		
		return false;
	}
	
	//_step also returns if the branch has ended
	static _step = function(_spd) {
		if (_ended || _paused) return _ended;
		
		_spd *= _speed;
		
		_global._script_stack_push(_live_script);
		
		//run step
		if (_running_event != undefined) {
			#region get delta time
			var _dt;
			switch (_running_event._time_units) {
				case cutscene_time_units_frames: _dt = _spd; break;
				case cutscene_time_units_seconds: _dt = _spd / game_get_speed(gamespeed_fps); break;
				case cutscene_time_units_seconds_dt: _dt = _spd * delta_time / 1_000_000; break;
			}
			#endregion
			
			_running_event._step(_dt);
		}
		
		//run next event
		if (_initialize_event) _init_event();
		
		_global._script_stack_pop();
		
		return _ended;
	}
	
	static _init_event = function() {
		_initialize_event = true;
		_running_event = undefined;
		do {
			//check for live defined events
			if (array_length(_live_script._events) > 0) {
				_callstack_push(_live_script);
				_global._script_stack_pop();
				_live_script = new __cutscene_script_class();
				_global._script_stack_push(_live_script);
			}
			
			while (_callstack_top._event_index >= array_length(_callstack_top._events)) {
				var _popped = _callstack_pop();
				if (!_popped) { //callstack is empty
					_ended = true;
					return;
				}
			}
			
			//run event
			var _event = _callstack_top._events[_callstack_top._event_index];
			
			if (_event._type = __cutscene_event_type._constructor) {
				_initialize_event = false;
				_running_event = new _event._constructor(_event._parameter);
			} else {
				_callstack_top._event_index++;
				_event._method(_event._parameter);
			}
		} until (!_initialize_event)
	}
	
	#region callstack
	static _callstack_push = function(_script, _event_index = 0) {
		_callstack_top = {
			_event_index: _event_index,
			_events: _script._events,
			_labels: _script._labels,
		};
		array_push(_callstack, _callstack_top);
	}
	
	static _callstack_pop = function() {
		if (array_length(_callstack) <= 1) return false;
		array_pop(_callstack);
		_callstack_top = array_last(_callstack);
		return true;
	}
	
	static _callstack_return_to_index = function(_index) {
		var _size = _index + 1;
		if (_size >= array_length(_callstack)) return;
		array_resize(_callstack, _size);
		_callstack_top = array_last(_callstack);
	}
	#endregion
}
#endregion

#region old stuff
/*
function cutscene_create() {
	var inst = instance_create_depth(0, 0, 0, __cutscene_handler);
	inst.parentScope = method_get_self(method(self, cutscene_create));
	__cutscene_get_data().current = inst;
	return inst;
}

function cutscene_set_autodestroy(cutscene = __cutscene_get_data().current, enable) {
	cutscene.autoDestroy = enable;
}

function cutscene_destroy(cutscene = __cutscene_get_data().current) {
	if instance_exists(cutscene) {
		instance_destroy(cutscene);
	}
}

function cutscene_start(cutscene = __cutscene_get_data().current) {
	cutscene.play = true;
}

function cutscene_next(cutscene = __cutscene_get_data().current) {
	cutscene.currentThread.sceneIndex ++;
}

function cutscene_pause(cutscene = __cutscene_get_data().current) {
	cutscene.play = false;
}

function cutscene_unpause(cutscene = __cutscene_get_data().current) {
	cutscene.play = true;
}

#region wrappers
function cutscene_wrapper(getter_method = undefined, setter_method = undefined) {
	return {
		get: getter_method ?? function() { return value; },
		set: setter_method ?? function(v) { value = v; },
		value: 0
	}
}

function cutscene_wrapper_value(value) {
	var wrapper = cutscene_wrapper();
	wrapper.set(value);
}

function cutscene_wrapper_set(wrapper, value) {
	wrapper.set(value);
}

function cutscene_wrapper_get(wrapper) {
	return wrapper.get();
}
#endregion

function cutscene_use_variables(cutscene = __cutscene_get_data().current, use_variables) {
	cutscene.useStringVariables = use_variables;
}

#region internal
///@ignore
function __cutscene_get_data() {
	static data = {current: noone};
	return data;
}
#endregion
*/ #endregion