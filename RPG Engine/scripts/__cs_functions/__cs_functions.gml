function cs_test_method(_parameter) {
	static _method = function(_parameter) {
		show_debug_message(_parameter);
	}
	cutscene_add_event_method(_method, _parameter);
}

#region basic
function cs_func_ext(_function, _array_args) {
	static _method = function(_parameters) {
		method_call(_parameters[0], _parameters[1]);
	}
	if (!is_method(_function)) _function = method(self, _function);
	var _parameters = [_function, _array_args];
	cutscene_add_event_method(_method, _parameters);
}

function cs_func(_function, _arg0 = undefined) {
	if (argument_count > 2) {
		var _array_args = array_create(argument_count - 1);
		for (var _i = 1; _i < argument_count; _i++) {
			_array_args[_i - 1] = argument[_i];
		}
		cs_func_ext(_function, _array_args);
		return;
	}
	if (!is_method(_function)) _function = method(self, _function);
	cutscene_add_event_method(_function, _arg0);
}

function cs_label(_label_name) {
	cutscene_add_label(_label_name);
}

function cs_goto_label(_label_name) {
	static _method = function(_label_name) {
		cutscene_goto_label(cutscene_branch_get_current(), _label_name);
	}
	cutscene_add_event_method(_method, _label_name);
}

function cs_stop() {
	static _method = function() {
		cutscene_stop(cutscene_branch_get_current());
	}
	cutscene_add_event_method(_method);
}

function cs_time_units(_time_units) {
	static _method = function(_time_units) {
		cutscene_time_units(cutscene_branch_get_current(), _time_units);
	}
	cutscene_add_event_method(_method, _time_units);
}
#endregion

#region branches
function cs_branch_begin(_branch_name = "") {
	cs_branch_begin_child(cutscene_branch_root, _branch_name);
}

function cs_branch_begin_child(_parent_branch_name, _branch_name = "") {
	static _method = function(_parameters) {
		cutscene_branch_create(cutscene_get_branch(cutscene_get_current(), _parameters[0]), _parameters[1], _parameters[2]);
	}
	var _template = cutscene_template_create();
	cutscene_add_event_method(_method, [_parent_branch_name, _template, _branch_name]);
	cutscene_template_begin(_template);
}

function cs_branch_end() {
	cutscene_template_end();
}
#endregion

#region anime
function cs_anime_begin(_val, _call_method) {
	static _class = function(_anime) constructor {
		self._anime = anime_clone(_anime);
		
		static _step = function(_dt) {
			anime_step(_anime, _dt);
		}
	}
	
	var _anime = anime_begin_ext(_val, false, false, 1, _call_method, cutscene_event_next);
	cutscene_add_event(_class, _anime);
}

function cs_anime_end() {
	anime_end();
}

function cs_anime_add(_val, _time, _easing_curve = anime_curve.linear) {
	anime_add(_val, _time, _easing_curve);
}

function cs_anime_tween(_val1, _val2, _time, _easing_curve, _call_method) {
	static _class = function(_parameters) constructor {
		_val1 = _parameters._val1;
		_val2 = _parameters._val2;
		_length = _parameters._time;
		_time = 0;
		_easing_curve = _parameters._easing_curve;
		_call_method = _parameters._call_method;
		
		static _step = function(_dt) {
			_time += _dt;
			var _amount = min(_time / _length, 1);
			_call_method(anime_curve_lerp(_val1, _val2, _amount, _easing_curve));
			if (_time >= _length) cutscene_event_next(_time - _length);
		}
	}
	
	cutscene_add_event(_class, {_val1, _val2, _time, _easing_curve, _call_method});
}
#endregion

function cs_wait(_time) {
	static _class = function(_time) constructor {
		_length = _time;
		self._time = 0;
		
		static _step = function(_dt) {
			_time += _dt;
			if (_time >= _length) cutscene_event_next(_time - _length);
		}
	}
	
	cutscene_add_event(_class, _time);
}

#region objects
function cs_obj_move(_object, _x, _y, _time) {
	static _method = function(_parameters) {
		var _object = _parameters._object;
		_object.x = _parameters._x;
		_object.y = _parameters._y;
	}
	
	static _class = function(_parameters) constructor {
		_object = _parameters._object;
		_x1 = _object.x;
		_y1 = _object.y;
		_x2 = _parameters._x;
		_y2 = _parameters._y;
		_length = _parameters._time;
		_time = 0;
		
		static _step = function(_dt) {
			_time += _dt;
			var _amount = min(_time / _length, 1);
			_object.x = lerp(_x1, _x2, _amount);
			_object.y = lerp(_y1, _y2, _amount);
			
			if (_time >= _length) cutscene_event_next(_time - _length);
		}
	}
	
	if (_time > 0) {
		cutscene_add_event(_class, {_object, _x, _y, _time});
	} else {
		cutscene_add_event_method(_method, {_object, _x, _y});
	}
}

function cs_obj_move_speed(_object, _x, _y, _speed) {
	static _method = function(_parameters) {
		var _object = _parameters._object;
		var _x = _parameters._x;
		var _y = _parameters._y;
		cs_obj_move(_object, _x, _y, sqrt(sqr(_x - _object.x) + sqr(_y - _object.y)) / _parameters._speed)
	}
	cutscene_add_event_method(_method, {_object, _x, _y, _speed})
}

function cs_obj_move_relative(_object, _x, _y, _time) {
	static _method = function(_parameters) {
		var _object = _parameters._object;
		cs_obj_move(_object, _object.x + _parameters._x, _object.y + _parameters._y, _parameters._time)
	}
	cutscene_add_event_method(_method, {_object, _x, _y, _time})
}
#endregion