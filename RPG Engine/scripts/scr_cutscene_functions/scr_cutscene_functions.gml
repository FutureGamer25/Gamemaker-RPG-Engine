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
	_cutscene._next();
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
	_script._push(new __cutscene_constructor_class(_constructor, _parameter, _global._time_units));
}

function cutscene_add_method(_method, _parameter = undefined) {
	static _global = __cutscene_get_global();
	var _script = _global._script_current;
	if (_script = undefined) return;
	_script._push(new __cutscene_method_class(_method, _parameter));
}
#endregion



#region internal

#region global
#macro cutscene_time_units_frames 0
#macro cutscene_time_units_seconds 1
#macro cutscene_time_units_seconds_dt 2

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
		
		_time_units_methods = [];
		_time_units_methods[cutscene_time_units_frames] = function(_spd) { return _spd; };
		_time_units_methods[cutscene_time_units_seconds] = function(_spd) { return _spd / game_get_speed(gamespeed_fps); };
		_time_units_methods[cutscene_time_units_seconds_dt] = function(_spd) { return _spd * delta_time / 1_000_000; };
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

function __cutscene_class(_script) constructor {
	static _start = function() {
		if (!time_source_exists(_time_source)) {
			_time_source = time_source_create(time_source_game, 1, time_source_units_frames, _step, [], -1);
		}
	}
	
	static _stop = function() {
		//if (time_source_exists(_time_source)) time_source_destroy(_time_source);
		_main_branch.a()
	}
	
	static _set_paused = function(_paused) {
		_main_branch._paused = _paused;
	}
	
	static _set_speed = function(_speed) {
		_main_branch._speed = _speed;
	}
	
	_step = function() {
		var _ended = _main_branch._step(1);
		//if (_ended) _stop();
		if (_ended) time_source_destroy(_time_source);
	}
	
	_main_branch = new __cutscene_branch_class(_script);
	_time_source = undefined;
	_branch_names = {};
}

function __cutscene_script_class() constructor {
	static _push = function(_event) {
		array_push(_events, _event);
	}
	_events = [];
	_labels = {};
}

function __cutscene_branch_class(_script, _event_index = 0) constructor {
	_paused = false;
	_speed = 1;
	_has_name = false; //is referenced in _branch_names
	
	_callstack = [];
	self._script = _script;
	self._event_index = _event_index - 1;
	
	_running_event = undefined;
	_running_get_dt = undefined;
	_run_next_event = true;
	_live_script = new __cutscene_script_class();
	_child_branches = [];
	
	static _global = __cutscene_get_global();
	
	static _start = function() {
		_event_index = -1;
		_running_event = undefined;
		_run_next_event = true;
	}
	
	static _stop = function() {
		_event_index = array_length(_script._events);
	}
	
	static _next = function() {
		_run_next_event = true;
	}
	
	static _step = function(_spd) {
		if (_paused) return !_has_name; //if nameless can be removed
		
		_spd *= _speed;
		
		//run events
		if (_event_index < array_length(_script._events)) {
			_run_events(_spd);
		} else {
			if (array_length(_child_branches) = 0) return !_has_name; //no branches and nameless
		}
		
		//run child branches
		for (var i=array_length(_child_branches)-1; i>=0; i--) {
			var _ended = _child_branches[i]._step(_spd);
			if (_ended) array_delete(_child_branches, i, 1);
		}
		
		return false;
	}
	
	static _run_events = function(_spd) {
		_global._script_stack_push(_live_script);
		
		//run step
		if (_running_event != undefined) _running_event._step(_running_get_dt(_spd));
		
		//progress to next event
		while (_run_next_event) {
			//check for live defined events
			if (array_length(_live_script._events) > 0) {
				_global._script_stack_pop();
				_callstack_push(_live_script);
				_live_script = new __cutscene_script_class();
				_global._script_stack_push(_live_script);
			}
			
			_event_index ++;
			
			if (_event_index >= array_length(_script._events)) {
				if (_callstack_pop()) {
					continue; //continue on previous script
				} else {
					_running_event = undefined;
					break; //callstack is empty and the branch has finished
				}
			}
			
			//run event
			var _event = _script._events[_event_index];
			if (_event._type = __cutscene_event_type._constructor) {
				_run_next_event = false;
				_running_get_dt = _global._time_units_methods[_event._time_units];
				_running_event = new _event._constructor(_event._parameter);
			} else {
				_event._method(_event._parameter);
			}
		}
		
		_global._script_stack_pop();
	}
	
	static _callstack_push = function(_script, _event_index = 0) {
		array_push(_callstack, {_script: self._script, _event_index: self._event_index});
		self._script = _script;
		self._event_index = _event_index - 1;
	}
	
	static _callstack_pop = function() {
		var _top = array_pop(_callstack);
		if (_top = undefined) return false;
		_script = _top._script;
		_event_index = _top._event_index;
		return true;
	}
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