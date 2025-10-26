function cs_test_method(_parameter) {
	static _method = function(_parameter) {
		show_debug_message(_parameter);
	}
	
	cutscene_add_event_method(_method, _parameter);
}

function cs_call_ext(_function, _array_args) {
	static _method = function(_parameters) {
		with (_parameters[0]) script_execute_ext(_parameters[1], _parameters[2]);
	}
	
	var _self = self;
	if (is_method(_function)) {
		_self = method_get_self(_function);
		_function = method_get_index(_function);
	}
	
	var _parameters = [_self, _function, _array_args];
	cutscene_add_event_method(_method, _parameters);
}

function cs_call(_function, _arg0 = undefined) {
	if (argument_count > 2) {
		var _array_args = array_create(argument_count - 1);
		for (var _i = 1; _i < argument_count; _i++) {
			_array_args[_i - 1] = argument[_i];
		}
		cs_call_ext(_function, _array_args);
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
		cutscene_goto_label(cutscene_get_current(), _label_name);
	}
	
	cutscene_add_event_method(_method, _label_name);
}

function cs_branch_begin(_branch_name = "") {
	static _method = function(_parameters) {
		cutscene_branch_start(cutscene_get_current(), _parameters[0], _parameters[1]);
	}
	
	var _script = cutscene_script_create();
	cutscene_add_event_method(_method, [_script, _branch_name]);
	cutscene_script_begin_append(_script);
}

function cs_branch_end() {
	cutscene_script_end();
}

function cs_wait(_time) {
	static _class = function(_cutscene, _time) constructor {
		self._cutscene = _cutscene;
		_time_max = _time;
		self._time = 0;
		
		static _create = function() {}
		
		static _step = function(_dt) {
			_time += _dt;
			if (_time >= _time_max) cutscene_next(_cutscene, _time - _time_max);
		}
	}
	
	cutscene_add_event(_class, _time);
}