cutscene_set_time_units(cutscene_time_units_seconds); //can also change units mid cutscene (maybe...)
//cutscene_time_units_frames
//cutscene_time_units_seconds
//cutscene_time_units_seconds_dt

//affects functions such as...
//cs_wait(time);
//cs_obj_move(inst, x, y, time);
//etc.


//---new cutscene functions---
cutscene_get_current()
cutscene_start([cutscene])
cutscene_stop([cutscene])
cutscene_pause([cutscene])
cutscene_resume([cutscene])

cutscene_begin()
cutscene_end()
cutscene_template_begin()
cutscene_template_end()
cutscene_from_template(template)

cutscene_automatic_step(cutscene, enable)
cutscene_step(cutscene)
cutscene_next([cutscene])


//---macros---
cutscene_branch_main
cutscene_branch_current


//---new scene functions---
cs_end()
//stops current branch
cs_branch_pause(branch_name)
cs_branch_resume(branch_name)
cs_branch_stop(branch_name)

cs_branch_begin([name])
cs_branch_end()
cs_branch_from_template(template)
cs_branch_layer_begin([main_branch_name])
cs_branch_layer_end()


//branch example
cutscene_begin();
cs_do_thing();
cs_do_thing();

cs_branch_layer_begin();
	cs_branch_begin();
		cs_char_walk(obj_jimmy, 50, 30, 5);
		cs_branch_begin("dust");
			cs_spawn_dust(obj_jimmy, 8, 16);
		cs_branch_end();
	cs_branch_end();
	cs_char_walk(obj_james, 100, 30, 5);
cs_branch_layer_end();

cs_do_last_thing();
cutscene_end();


//branch example 2
cutscene_begin();
cs_do_thing();
cs_do_thing();

cs_branch_begin("jimmy");
	cs_char_walk(obj_jimmy, 50, 30, 5);
	cs_branch_begin("dust");
		cs_spawn_dust(obj_jimmy, 8, 16);
	cs_branch_end();
cs_branch_end();

cs_branch_begin("james");
	cs_char_walk(obj_james, 100, 30, 5);
cs_branch_end();
cs_await_branches(["jimmy", "james", "dust"])

cs_do_last_thing();
cutscene_end();


//---templates---
template1 = cutscene_template_begin();
//do something
cs_branch_begin("branch1");
	cs_label("loop");
	//do something
	cs_goto("loop");
cs_branch_end();
cs_wait(5);
cs_branch_set_speed("branch1", 2);
cs_wait(5);
cs_branch_pause("branch1");
cutscene_template_end();

cutscene_start_template(template1);


//---actual cutscenes---
cutscene_begin();
cs_obj_move_relative(obj_player, 0, 32, 1);
cs_wait(2);
cs_template(template1);
cs_lerp(/*idk stuff here*/);
cs_anim_begin(0);
cs_anim_pos(5, 1);
cs_anim_pos(3, 1);
cs_anim_end();
cutscene_end();
//cutscene runs automatically



function cs_wait(_time) {
	static _wait = function(_time) constructor {
		_timer = _time;
		static _step = function(_dt) {
			_timer -= _dt;
			if (_timer <= 0) cutscene_next();
		}
	}
	cutscene_add_event(_wait, _time);
}

//alternate (kinda ass)
function cs_wait(_time) {
	static _func = function(_time) {
		static _wait = function(_time) constructor {
			_timer = _time;
			static _step = function(_dt) {
				_timer -= _dt;
				if (_timer <= 0) cutscene_next();
			}
		}
		cutscene_set_step(new _wait(_time)._step);
	}
	cs_call(_func, _time);
}


function cs_obj_destroy(_inst) {
	static _func = function(_inst) {
		instance_destroy(_inst);
	}
	cs_call(_func, _inst);
}

//alternate (EVIL AF NOT ALLOWED!!!)
function cs_obj_destroy(_inst) {
	static _func = function(_inst) constructor {
		instance_destroy(_inst);
	}
	cutscene_add_event(_func, _inst);
}


function cs_lerp(_val1, _val2, _time, _callback) {
	cs_add_interpolator();
}


//---event implementation---
enum __cutscene_event_type {
	_constructor, _method
}

function __cutscene_constructor_class(_constructor, _parameter, _time_units) constructor {
	static _type = __cutscene_event_type._class;
	self._constructor = _constructor;
	self._parameter = _parameter;
	self._time_units = _time_units;
}

function __cutscene_method_class(_method, _parameter) constructor {
	static _type = __cutscene_event_type._method;
	self._method = _method;
	self._parameter = _parameter;
}

function cutscene_add_event(_constructor, _parameter) {
	static _global = __cutscene_get_global();
	if (_global._script_current = undefined) return;
	_global._script_current._push(new __cutscene_constructor_class(_constructor, _parameter, _global._time_units));
}


//---script/template implementation---
function __cutscene_script_class() constructor {
	static _push = function(_event) {
		array_push(_events, _event);
	}
	_events = [];
	_labels = {};
}


//---cutscene implementation---
function __cutscene_class(_script) constructor {
	self._script = _script;
	_branch_count = 0;
	_branch_names = {};
	_branches = [];
	_time_unit_scalers = [1, 1, 1];
	
	_step = function() {
		_time_unit_scalers[cutscene_time_units_seconds] = 1 / game_get_speed(gamespeed_fps);
		_time_unit_scalers[cutscene_time_units_seconds_dt] = delta_time / 1_000_000;
		
		for (var _i = array_length(_branches) - 1; _i >= 0; _i--) {
			var _ended = _branches[_i]._step(1, _time_unit_scalers);
			if (ended) _branch_remove(_branch);
		}
		
		for (var _i = array_length(_branches) - 1; _i >= 0; _i--) {
			if (_branch._removed) array_delete(_branches, _i);
		}
	}
	
	_branch_add(_branch) = function {
		_branch_count++;
		_branch_names[$ _branch._name] = _branch;
		array_push(_branches, _branch);
	}
	
	_branch_remove(_branch) = function {
		if (_branch._destroyed) return;
		_branch._destroyed = true;
		_branch_count--;
		struct_remove(_branch_names, _branch._name);
	}
}


//---branch implementation---
function __cutscene_branch_class(_script, _name = "") constructor {
	self._name = _name; //used by __cutscene_class
	_removed = false; //used by __cutscene_class
	
	_paused = false;
	_speed = 1;
	self._script = _script;
	self._event_index = 0;
	_callstack = [];
	
	_initialize_event = true;
	_running_event = undefined;
	_live_script = new __cutscene_script_class();
	_child_branches = [];
	
	static _global = __cutscene_get_global();
	
	static _step = function(_spd, _time_unit_scalers) {
		if (_paused) return false;
		
		_spd *= _speed;
		
		//run events
		if (_event_index < array_length(_script._events)) {
			_global._script_stack_push(_live_script);
			
			//run step
			if (_running_event != undefined) {
				//#region get delta time
				//var _time_units = _running_event._time_units;
				//var _dt = _spd;
				//if (_time_units = cutscene_time_units_seconds) {
				//	_dt /= game_get_speed(gamespeed_fps);
				//} else if (_time_units = cutscene_time_units_seconds_dt) {
				//	_dt *= delta_time / 1_000_000;
				//}
				//
				//var _dt;
				//switch (_running_event._time_units) {
				//	case cutscene_time_units_frames: _dt = _spd; break;
				//	case cutscene_time_units_seconds: _dt = _spd / game_get_speed(gamespeed_fps); break;
				//	case cutscene_time_units_seconds_dt: _dt = _spd * delta_time / 1_000_000; break;
				//}
				//#endregion
				
				_running_event._step(_spd * _time_unit_scalers[_running_event._time_units]);
			}
			
			//progress to next event
			if (_initialize_event) {
				_init_event();
			}
			
			_global._script_stack_pop();
		}
	}
	
	static _init_event = function() {
		_initialize_event = true;
		do {
			//check for live defined events
			if (array_length(_live_script._events) > 0) {
				_callstack_push(_live_script);
				_global._script_stack_pop();
				_live_script = new __cutscene_script_class();
				_global._script_stack_push(_live_script);
			}
			
			while (_event_index >= array_length(_script._events)) {
				var _success = _callstack_pop();
				if (!_success) return; //callstack is empty
			}
			
			//run event
			var _event = _script._events[_event_index];
			
			if (_event._type = __cutscene_event_type._constructor) {
				_initialize_event = false;
				_running_event = new _event._constructor(_event._parameter);
			} else {
				_event_index++;
				_event._method(_event._parameter);
			}
		} until (!_initialize_event)
	}
	
	static _callstack_push = function(_script, _event_index = 0) {
		array_push(_callstack, {_script: self._script, _event_index: self._event_index});
		self._script = _script;
		self._event_index = _event_index;
	}
	
	static _callstack_pop = function() {
		var _top = array_pop(_callstack);
		if (_top = undefined) return false;
		_script = _top._script;
		_event_index = _top._event_index;
		return true;
	}
}


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
		_script_stack = [];
		_script_current = undefined;
		_time_units = cutscene_time_units_frames;
	}
	static _global = new _class();
	return _global;
}



//BULLCRAP TIME!!!
//event running
FUNCTION run_events(script)
	WHILE there's still events to run
		get event from the script
		call event
		
		WHILE there is a running event
			wait a frame
			run the event step
		END WHILE
		
		IF there is events on the live script
			run_events(live script)
		END IF
		
		_event_index ++;
	END WHILE
END FUNCTION


run current step
if (next event) {
	
}


function cutscene_goto(cutscene, label_name) {
	_initialize_event = true;
	_event_index = (idk get the index from the label);
}

//goto the next event
//if called repeatedly will skip multiple events
function cutscene_next(cutscene, branch_name = "__current__") {
	_initialize_event = true;
	_event_index ++;
}