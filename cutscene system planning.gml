cutscene_set_time_units(cutscene_time_units_seconds); //can also change units mid cutscene (maybe...)
//cutscene_time_units_frames
//cutscene_time_units_seconds
//cutscene_time_units_seconds_dt

//affects functions such as...
//cs_wait(time);
//cs_obj_move(inst, x, y, time);
//etc.


//---new cutscene functions---
cutscene_start()
cutscene_pause()
cutscene_resume()
cutscene_stop()

cutscene_automatic_step(cutscene, enable)
cutscene_step()
cuscene_next()


//---new scene functions---
cs_stop() //ends cutscene
cs_branch_pause(branch_name)
cs_branch_resume(branch_name)


//---templates---
template1 = cutscene_template_begin();
//do something
cs_branch_start("branch1");
	cs_label("loop");
	//do something
	cs_goto("loop");
cs_branch_end();
cs_wait(5);
cs_branch_set_speed("branch1", 2);
cs_wait(5);
cs_branch_pause("branch1");
cutscene_template_end();


//---actual cutscenes---
cutscene_begin();
cs_obj_move_relative(obj_player, 0, 32, 1);
cs_wait(2);
cs_template(template1);
cs_lerp(/*idk stuff here*/);
cs_anim_start(0);
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
function __cutscene_class() constructor {
	_branch_names = {};
}


//---branch implementation---
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
			var _remove = _child_branches[i]._step(_spd);
			if (_remove) array_delete(_child_branches, i, 1);
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
		
		_time_units_methods = [];
		_time_units_methods[cutscene_time_units_frames] = function(_spd) { return _spd; };
		_time_units_methods[cutscene_time_units_seconds] = function(_spd) { return _spd / game_get_speed(gamespeed_fps); };
		_time_units_methods[cutscene_time_units_seconds_dt] = function(_spd) { return _spd * delta_time / 1_000_000; };
	}
	static _global = new _class();
	return _global;
}



//BULLCRAP TIME!!!
//event running

FUNCTION run_events(script)
	FOR each event in the script
		get event from the script
		call event
		
		WHILE there is a running event
			wait a frame
			run the event step
		END WHILE
		
		IF there is events on the live script
			run_events(live script)
		END IF
	END FOR
END FUNCTION

function _run_events(_spd) {
	while
}

function cutscene_goto(cutscene, label_name) {
	
}

//goto the next event
//if called repeatedly will skip multiple events
function cutscene_next(cutscene, branch_name = "__current__") {

}