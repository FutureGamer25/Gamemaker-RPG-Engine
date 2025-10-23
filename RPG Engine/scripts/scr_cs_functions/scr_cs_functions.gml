function cs_test_method(_parameter) {
	static _method = function(_parameter) {
		show_message(_parameter);
	}
	
	cutscene_add_method(_method, _parameter);
}

function cs_call_ext(_function, _array_args) {
	static _method = function(_parameters) {
		with (_parameters[0]) script_execute_ext(_parameters[1], _parameters, 2);
	}
	
	var _self = self;
	if (is_method(_function)) {
		_self = method_get_self(_function);
		_function = method_get_index(_function);
	}
	
	var _len = array_length(_array_args);
	var _parameters = array_create(_len + 2);
	_parameters[0] = _self;
	_parameters[1] = _function;
	array_copy(_parameters, 2, _array_args, 0, _len);
	cutscene_add_method(_method, _parameters);
}

function cs_call(_function, _arg0 = undefined) {
	if (argument_count > 2) {
		var _array_args = array_create(argument_count - 1);
		_array_args[0] = _arg0;
		for (var _i = 2; _i < argument_count; _i++) {
			_array_args[_i - 1] = argument[_i];
		}
		cs_call_ext(_function, _array_args);
		return;
	}
	
	if (!is_method(_function)) _function = method(self, _function);
	cutscene_add_method(_function, _arg0);
}