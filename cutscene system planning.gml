cutscene_set_time_units(cutscene_time_units_seconds); //can also change units mid cutscene (maybe...)
//cutscene_time_units_frames
//cutscene_time_units_seconds
//cutscene_time_units_seconds_dt

//affects functions such as...
//scene_wait(time);
//scene_obj_move(inst, x, y, time);
//etc.


//---templates---
template1 = cutscene_template_start();
//do something
scene_branch_start("branch1");
	scene_label("loop");
	//do something
	scene_goto("loop");
scene_branch_end();
scene_wait(5);
scene_branch_set_speed("branch1", 2);
scene_wait(5);
scene_branch_pause("branch1");


//---actual cutscenes---
cutscene_start();
scene_obj_move_relative(obj_player, 0, 32, 1);
scene_wait(2);
scene_template(template1);
scene_lerp(/*idk stuff here*/);
scene_anim_start(0);
scene_anim_pos(5, 1);
scene_anim_pos(3, 1);
scene_anim_end();
//cutscene runs automatically



function scene_wait(_time) {
	static _wait = function(_time) constructor {
		_timer = _time;
		static _step = function(_dt) {
			_timer -= _dt;
			if (_timer <= 0) cutscene_next();
		}
	}
	scene_add_event(_wait, _time);
}

//alternate
function scene_wait(_time) {
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
	scene_call(_func, _time);
}


function scene_obj_destroy(_inst) {
	static _func = function(_inst) {
		instance_destroy(_inst);
	}
	scene_call(_func, _inst);
}

//alternate
function scene_obj_destroy(_inst) {
	static _func = function(_inst) constructor {
		instance_destroy(_inst);
	}
	scene_add_event(_func, _inst);
}


function scene_lerp(_val1, _val2, _time, _callback) {
	scene_add_interpolator();
}



//---script implementation---
function __cutscene_script_class() constructor {
	_instructions = [];
	_time_units = [];
}


//---cutscene implementation---
function __cutscene_class() constructor {
	_branch_names = {};
}


//---branch implementation---
function __cutscene_branch_class(_script, _pos = 0) constructor {
	_paused = false;
	_speed = 1;
	_has_name = false; //is referenced in _branch_names
	_callstack = [];
	_branches = [];
	
	static _step = function(_spd) {
		if (_paused) return _has_name; //if nameless can be removed
		
		_spd *= _speed;
		
		//run self
		var _current = array_last(_callstack);
		var _pos = _current._pos;
		var _script = _current._script;
		if (_pos < array_length(_script)) {
			//now actually run self
			//kinda hate the switch maybe kill it
			//var _dt;
			//switch (_script._time_units[_pos]) {
			//	case cutscene_time_units_frames: _dt = _spd; break;
			//	case cutscene_time_units_seconds: _dt = _spd / game_get_speed(gamespeed_fps); break;
			//	case cutscene_time_units_seconds_dt: _dt = _spd * delta_time / 1_000_000; break;
			//}
			
			//run event
		} else {
			if (array_length(_branches) = 0) return _has_name; //no branches and nameless
		}
		
		//run child branches
		for (var i=array_length(_branches)-1; i>=0; i--) {
			var _remove = _branches[i]._step(_spd);
			if (_remove) array_delete(_branches, i, 1);
		}
		
		return true;
	}
}


function __cutscene_get_global() {
	static _struct = {
		_script_stack: []
	};
	return _struct;
}