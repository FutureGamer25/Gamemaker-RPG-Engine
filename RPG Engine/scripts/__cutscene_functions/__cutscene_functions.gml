#region cutscene general

///@param {Bool} auto_start Start the cutscene automatically (defaults to true)
function cutscene_begin(_auto_start = true) {
	var _template = cutscene_template_begin();
	return cutscene_create_from_template(_template, _auto_start);
}

function cutscene_end() {
	cutscene_template_end();
}

function cutscene_create_from_template(_template, _auto_start = true) {
	var _cutscene = new __cutscene_class(_template);
	if (_auto_start) _cutscene._start();
	return _cutscene;
}

function cutscene_get_current() {
	static _global = __cutscene_global();
	return _global._current_branch._cutscene;
}

function cutscene_branch_get_current() {
	static _global = __cutscene_global();
	return _global._current_branch;
}

function cutscene_event_next(_time_remaining = 0) {
	static _global = __cutscene_global();
	_global._current_branch._next(_time_remaining);
}
#endregion

#region cutscene operations
function cutscene_start(_cutscene) {
	_cutscene._start();
}

function cutscene_branch_create(_cutscene_or_parent_branch, _template, _branch_name = "") {
	return _cutscene_or_parent_branch._create_branch(_template, _branch_name);
}

function cutscene_get_branch(_cutscene, _branch_name) {
	return _cutscene._get_branch(_branch_name);
}

function cutscene_stop(_cutscene_or_branch) {
	_cutscene_or_branch._stop();
}

function cutscene_pause(_cutscene_or_branch) {
	_cutscene_or_branch._pause();
}

function cutscene_resume(_cutscene_or_branch) {
	_cutscene_or_branch._resume();
}

function cutscene_get_state(_cutscene_or_branch) {
	return _cutscene_or_branch._state;
}

function cutscene_set_speed(_cutscene_or_branch, _speed) {
	_cutscene_or_branch._set_speed(_speed);
}

function cutscene_get_speed(_cutscene_or_branch) {
	return _cutscene_or_branch._get_speed();
}

function cutscene_time_units(_cutscene_or_branch, _time_units) {
	_cutscene_or_branch._set_time_units(_time_units);
}

function cutscene_goto_label(_cutscene_or_branch, _label_name) {
	_cutscene_or_branch._goto(_label_name);
}

function cutscene_enable_step(_cutscene, _enable) {
	_cutscene._enable_step(_enable);
}

function cutscene_step(_cutscene, _frames = 1) {
	_cutscene._step(_frames);
}
#endregion

#region templates
function cutscene_template_begin(_append_to_template = cutscene_template_create()) {
	var _global = __cutscene_global();
	_global._template_stack_push(_append_to_template);
	return _append_to_template;
}

function cutscene_template_end() {
	var _global = __cutscene_global();
	_global._template_stack_pop();
}

function cutscene_template_create() {
	return new __cutscene_template_class();
}

//function cutscene_template_get_current() {
//	static _global = __cutscene_global();
//	return _global._current_template;
//}
#endregion

#region events
function cutscene_add_event(_constructor, _parameter = undefined) {
	static _template_get_write = __cutscene_global()._template_get_write;
	var _template = _template_get_write();
	array_push(_template._events, new __cutscene_event_class(_constructor, _parameter));
}

function cutscene_add_event_method(_method, _parameter = undefined) {
	static _template_get_write = __cutscene_global()._template_get_write;
	var _template = _template_get_write();
	array_push(_template._events, new __cutscene_event_method_class(_method, _parameter));
}

function cutscene_add_label(_label_name) {
	static _template_get_write = __cutscene_global()._template_get_write;
	var _template = _template_get_write();
	_template._labels[$ _label_name] = array_length(_template._events);
}
#endregion

#region macros
#macro cutscene_branch_root "__root__"

#macro cutscene_units_frames 0
#macro cutscene_units_seconds 1
#macro cutscene_units_seconds_dt 2

#macro cutscene_state_initial 0
#macro cutscene_state_active 1
#macro cutscene_state_paused 2
#macro cutscene_state_stopped 3
#endregion



#region internal

///@ignore
function __cutscene_global() {
	static _class = function() constructor {
		_current_branch = undefined;
		_current_template = undefined;
		_template_stack = [];
		
		_template_stack_push = function(_template) {
			array_push(_template_stack, _template);
			_current_template = _template;
		}
		
		_template_stack_pop = function() {
			var _template = array_pop(_template_stack);
			_current_template = array_last(_template_stack);
			return _template;
		}
		
		_template_get_write = function() {
			if (_current_template == undefined) {
				if (_current_branch == undefined) return undefined;
				_current_template = new __cutscene_template_class();
				array_push(_template_stack, _current_template);
			}
			return _current_template;
		}
	}
	static _global = new _class();
	return _global;
}

#region templates / events

///@ignore
function __cutscene_template_class() constructor {
	_events = [];
	_labels = {};
}

///@ignore
enum __CUTSCENE_EVENT_TYPE {_DEFAULT, _METHOD}

///@ignore
function __cutscene_event_class(_runner_class, _parameter) constructor {
	static _type = __CUTSCENE_EVENT_TYPE._DEFAULT;
	self._runner_class = _runner_class;
	self._parameter = _parameter;
}

///@ignore
function __cutscene_event_method_class(_method, _parameter) constructor {
	static _type = __CUTSCENE_EVENT_TYPE._METHOD;
	self._method = _method;
	self._parameter = _parameter;
}

#endregion

#region cutscenes

///@ignore
function __cutscene_class(_template) : __cutscene_branch_class(_template, undefined, cutscene_branch_root) constructor {
	var _self = self;
	_branch_names = {cutscene_branch_root: _self};
	_time_source = undefined;
	_step_enabled = true;
	
	static _update_time_source = function() {
		if (_state == cutscene_state_active && _step_enabled) {
			if (!time_source_exists(_time_source)) {
				_time_source = time_source_create(time_source_game, 1, time_source_units_frames, method(self, _step), [1], -1);
				time_source_start(_time_source);
			}
		} else {
			if (time_source_exists(_time_source)) {
				time_source_destroy(_time_source);
			}
		}
	}
	
	static _enable_step = function(_enable) {
		_step_enabled = _enable;
		_update_time_source();
	}
	
	static _start_inherited = _start;
	static _stop_inherited = _stop;
	static _pause_inherited = _pause;
	static _resume_inherited = _resume;
	
	static _start = function() {
		_start_inherited();
		_update_time_source();
	}
	
	static _stop = function() {
		_stop_inherited();
		_update_time_source();
	}
	
	static _pause = function() {
		_pause_inherited();
		_update_time_source();
	}
	
	static _resume = function() {
		_resume_inherited();
		_update_time_source();
	}
	
	static _get_branch = function(_branch_name) {
		var _branch = _branch_names[$ _branch_name];
		return _branch;
	}
	
	static toString = function() {
		return $"struct cutscene {_child_branches}";
	}
}

///@ignore
function __cutscene_branch_class(_template, _cutscene = undefined, _name = "") constructor {
	self._cutscene = _cutscene ?? self;
	self._name = _name;
	_state = cutscene_state_initial;
	_speed = 1;
	_time_units = undefined;
	_time_remaining = 0;
	_child_branches = [];
	
	_script = _template;
	_event_index = 0;
	_event_instance = undefined;
	_callstack = [];
	
	_stop_callback = undefined;
	
	static _global = __cutscene_global();
	
	static _start = function() {
		if (_state != cutscene_state_initial) {
			_time_units = undefined;
			array_resize(_child_branches, 0);
			
			_callstack_return_to(0);
			_event_index = 0;
			_event_instance = undefined;
		}
		_state = cutscene_state_active;
	}
	
	static _stop = function() {
		_state = cutscene_state_stopped;
		if (_stop_callback != undefined) _stop_callback(self);
	}
	
	static _pause = function() {
		if (_state != cutscene_state_active) return;
		_state = cutscene_state_paused;
	}
	
	static _resume = function() {
		if (_state != cutscene_state_paused) return;
		_state = cutscene_state_active;
	}
	
	static _set_speed = function(_speed) { self._speed = _speed; }
	
	static _get_speed = function() { return _speed; }
	
	static _set_time_units = function(_time_units) {
		static _seconds = function() { return 1 / game_get_speed(gamespeed_fps); }
		static _seconds_dt = function() { return delta_time / 1_000_000; }
		switch (_time_units) {
			case cutscene_units_frames:     _time_units = undefined;   break;
			case cutscene_units_seconds:    _time_units = _seconds;    break;
			case cutscene_units_seconds_dt: _time_units = _seconds_dt; break;
		}
		self._time_units = _time_units;
		_time_remaining = 0;
	}
	
	static _step = function(_dt) {
		if (_state != cutscene_state_active) return (_state == cutscene_state_stopped);
		_dt *= _speed;
		
		//run child branches
		for (var _i = array_length(_child_branches) - 1; _i >= 0; _i--) {
			var _stopped = _child_branches[_i]._step(_dt);
			if (_stopped) array_delete(_child_branches, _i, 1);
		}
		
		var _branch_previous = _global._current_branch;
		_global._current_branch = self;
		_time_remaining = _dt * ((_time_units == undefined) ? 1 : _time_units());
		
		//run current branch
		while (_state == cutscene_state_active) {
			if (_event_instance == undefined) {
				//init event
				if (_event_index >= array_length(_script._events)) {
					var _is_empty = _callstack_pop();
					if (_is_empty) _state = cutscene_state_stopped;
					continue;
				}
				
				var _event = _script._events[_event_index];
				if (_event._type == __CUTSCENE_EVENT_TYPE._METHOD) {
					_event_index++;
					_event._method(_event._parameter);
				} else {
					_event_instance = new _event._runner_class(_event._parameter);
					//_event_instance._create(_event._parameter);
				}
			} else {
				//run event step
				if (_time_remaining == 0) break;
				var _time = _time_remaining;
				_time_remaining = 0;
				_event_instance._step(_time);
			}
			
			//push live events to the callstack
			if (_global._current_template != undefined) {
				_callstack_push(_global._current_template, 0);
				_global._template_stack_pop();
			}
		}
		
		_global._current_branch = _branch_previous;
		
		return (_state == cutscene_state_stopped);
	}
	
	static _next = function(_time_remaining) {
		_event_instance = undefined;
		_event_index++;
		self._time_remaining += _time_remaining;
	}
	
	static _goto = function(_label_name) {
		var _new_index = _script._labels[$ _label_name];
		if (_new_index != undefined) {
			_event_index = _new_index;
			_event_instance = undefined;
			return;
		}
		
		for (var _i = array_length(_callstack) - 1; _i >= 0; _i--) {
			_new_index = _callstack[_i]._script._labels[$ _label_name];
			if (_new_index != undefined) {
				_callstack_return_to(_i);
				_event_index = _new_index;
				_event_instance = undefined;
				return;
			}
		}
		
		show_message("CUTSCENE: Cannot goto label \"" + _label_name + "\".");
	}
	
	static _create_branch = function(_template, _name) {
		if (_cutscene._branch_names[$ _name] != undefined) _name = "";
		var _branch = new __cutscene_branch_class(_template, _cutscene, _name);
		if (_name != "") _cutscene._branch_names[$ _name] = _branch;
		_branch._stop_callback = function(_branch) {
			if (_branch._name != "") {
				struct_remove(_cutscene._branch_names, _branch._name);
				_branch._name = "";
			}
		}
		array_push(_child_branches, _branch);
		_branch._start();
		return _branch;
	}
	
	static _callstack_push = function(_new_script, _new_event_index) {
		array_push(_callstack, {_script, _event_index});
		_script = _new_script;
		_event_index = _new_event_index;
		_event_instance = undefined;
	}
	
	static _callstack_pop = function() {
		if (array_length(_callstack) <= 0) return true;
		var _previous = array_pop(_callstack);
		_script = _previous._script;
		_event_index = _previous._event_index;
		_event_instance = undefined;
		return false;
	}
	
	static _callstack_return_to = function(_callstack_index) {
		if (_callstack_index >= array_length(_callstack)) return;
		var _previous = _callstack[_callstack_index];
		array_resize(_callstack, _callstack_index);
		_script = _previous._script;
		_event_index = _previous._event_index;
		_event_instance = undefined;
	}
	
	static toString = function() {
		return "struct cutscene branch" + ((_name == "") ? "" : $" \"{_name}\"") + $" {_child_branches}";
	}
}

#endregion

#endregion