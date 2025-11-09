//feather ignore GM1042
//feather ignore GM2017

///@desc	Animates a value between two positions along a curve.
///			**NOTE:** For built-in easing curves use `anime_curve.[insert type]` or a string.
///			For custom curves use a function, animation curve, or animation curve channel.
///@param {Real} val1				The first value of the animation
///@param {Real} val2				The last value of the animation
///@param {Real} time				The duration in frames
///@param {Real|Function|Struct|Asset.GMAnimCurve} easing_curve
///									The easing curve
///@param {Function} call_method	The method to call for each frame of animation
///@return {Struct.__anime_class}
function anime_run(_val1, _val2, _time, _easing_curve, _call_method) {
	var _anime = new __anime_class(_val1, _call_method);
	_anime._add(_val2, _time, _easing_curve);
	return _anime;
}

function anime_begin(_val, _call_method = undefined) {
	static _global = __anime_global();
	var _anime = new __anime_class(_val, _call_method);
	_global._anime_current = _anime;
	_anime._start();
	return _anime;
}

function anime_begin_ext(_val, _speed, _loop, _disable_start = false, _call_method = undefined) {
	static _global = __anime_global();
	var _anime = new __anime_class(_val, _call_method);
	_global._anime_current = _anime;
	_anime._loop(_loop);
	if (!_disable_start) _anime._start();
	return _anime;
}

function anime_add(_val, _time, _easing_curve = anime_curve.linear) {
	static _global = __anime_global();
	_global._anime_current._add(_val, _time, _easing_curve);
}

function anime_end() {
	static _global = __anime_global();
	_global._anime_current = undefined;
}

function anime_start(_anime) {
	_anime._start();
}

function anime_stop(_anime) {
	if (!is_struct(_anime)) return;
	_anime._stop();
}

function anime_pause(_anime) {
	_anime._pause();
}

function anime_resume(_anime) {
	_anime._resume();
}

function anime_enable_loop(_anime, _enable = true) {
	_anime._loop(_enable);
}

function anime_set_speed(_anime, _speed) {
	_anime._set_speed(_speed);
}

///@desc	Sets the callback method.
///@param {Struct.__anime_class} anime	The anime instance
///@param {Function} call_method		The method to call for each frame of animation
function anime_set_method(_anime, _call_method) {
	_anime._set_method(_call_method);
}

function anime_skip(_anime, _time) {
	
}

function anime_get_value(_anime) {
	
}

function anime_clone(_anime) {
	return _anime._clone();
}

///@desc	Interpolate two values with an easing curve.
///			**NOTE:** For built-in easing curves use `anime_curve.[insert type]` or a string.
///			For custom curves use a function, animation curve, or animation curve channel.
///@param {Real} val1				The first value
///@param {Real} val2				The second value
///@param {Real} amount				The amount to interpolate
///@param {Real|String|Function|Struct|Asset.GMAnimCurve} easing_curve
//@param {Real|String|Struct} easing_curve
///									The easing curve
///@param {Real} [curve_dir]		The direction of the curve (only for custom curves)
///@return {Real}
function anime_curve_lerp(_val1, _val2, _amount, _easing_curve, _curve_dir = anime_curve_dir.normal) {
	static _curve_array = __anime_global()._curve_array;
	static _curve_struct = __anime_global()._curve_struct;
	//static _error = __anime_global()._error;
	
	static _animcurve_channel = undefined;
	static _animcurve_method = function(_amount) {
		return animcurve_channel_evaluate(_animcurve_channel, _amount);
	}
	
	if is_real(_easing_curve) { //built-in curve
		var _curve = _curve_array[_easing_curve];
		_easing_curve = _curve[0];
		_curve_dir = _curve[1];
	} else if is_string(_easing_curve) { //custom curve
		var _curve = _curve_struct[$ _easing_curve];
		_easing_curve = _curve[0];
		_curve_dir = _curve[1];
	} else if is_callable(_easing_curve) { //function
		if (!is_method(_easing_curve)) _easing_curve = method(self, _easing_curve);
	} else { //animcurve channel
		if animcurve_exists(_easing_curve) {
			//if is_handle(_easing_curve) _easing_curve = animcurve_get(_easing_curve);
			//if (array_length(_easing_curve.channels) <= 0) _error("Animation curves must have at least one channel.");
			_easing_curve = animcurve_get_channel(_easing_curve, 0);
		}
		_animcurve_channel = _easing_curve;
		_easing_curve = _animcurve_method;
	}
	
	switch (_curve_dir) {
		default: //normal
			return (_val2 - _val1) * _easing_curve(_amount) + _val1;
		case anime_curve_dir.reverse: //reverse
			return (_val1 - _val2) * _easing_curve(1 - _amount) + _val2;
		case anime_curve_dir.alternate: //normal-reverse
			_amount = 2 * _amount - 1;
			var _s1 = sign(_amount);
			return (_val2 - _val1) * (0.5 * (1 - _easing_curve(1 - _s1 * _amount)) * _s1 + 0.5) + _val1;
		case anime_curve_dir.alt_reverse: //reverse-normal
			_amount = 2 * _amount - 1;
			var _s2 = sign(_amount);
			return (_val2 - _val1) * (0.5 * _easing_curve(_s2 * _amount) * _s2 + 0.5) + _val1;
	}
}

#region macros / enums

#macro anime_state_initial 0
#macro anime_state_active 1
#macro anime_state_paused 2
#macro anime_state_stopped 3

enum anime_curve_dir {
	normal, reverse, alternate, alt_reverse
}

enum anime_curve {
	quad_in, quad_out, quad_in_out,
	
	cubic_in, cubic_out, cubic_in_out,
	
	quart_in, quart_out, quart_in_out,
	
	quint_in, quint_out, quint_in_out,
	
	expo_in, expo_out, expo_in_out,
	
	sine_in, sine_out, sine_in_out,
	
	circ_in, circ_out, circ_in_out,
	
	back_in, back_out, back_in_out,
	
	elastic_in, elastic_out, elastic_in_out,
	
	bounce_in, bounce_out, bounce_in_out,
	
	hold, linear
}

#endregion



#region internal

///@ignore
function __anime_global() {
	static _class = function() constructor {
		//_error = function(_message) {
		//	var _output = "ANIME: " + _message;
		//	show_message(_output);
		//	throw(_output);
		//}
		_anime_current = undefined;
		_curve_array = [];
		_curve_struct = {};
		
		#region curve methods
		var _linear = function(_val) { return _val; };
		var _hold = function(_val) { return (_val >= 1); };
		var _quad = function(_val) { return _val * _val; }
		var _cubic = function(_val) { return _val * _val * _val; }
		var _quart = function(_val) { return _val * _val * _val * _val; }
		var _quint = function(_val) { return _val * _val * _val * _val * _val; }
		var _expo = function(_val) { return (_val <= 0) ? 0 : exp(_val * 7 - 7); }
		var _sine = function(_val) { return sin(_val * pi * 0.5); }
		var _circ = function(_val) { return 1 - sqrt(max(1 - (_val * _val), 0)); }
		var _back = function(_val) {
			var _c1 = 1.70158;
			var _c3 = _c1 + 1;
			return (_c3 * _val - _c1) * _val * _val;
		}
		var _elastic = function(_val) {
			var _c4 = 2 * pi / 3;
			if (_val <= 0) return 0;
			if (_val >= 1) return 1;
			return power(2, -10 * _val) * sin((_val * 10 - 0.75) * _c4) + 1;
		}
		var _bounce = function(_val) {
			var _n1 = 7.5625;
			var _d1 = 2.75;
			if (_val < 1 / _d1) {
			    return _n1 * _val * _val;
			} else if (_val < 2 / _d1) {
				_val -= 1.5 / _d1;
			    return _n1 * _val * _val + 0.75;
			} else if (_val < 2.5 / _d1) {
				_val -= 2.25 / _d1;
			    return _n1 * _val * _val + 0.9375;
			} else {
				_val -= 2.625 / _d1;
			    return _n1 * _val * _val + 0.984375;
			}
		}
		#endregion
		
		#region register curves
		var _register = function(_index, _method, _direction) {
			_curve_array[_index] = [_method, _direction];
		}
		_register(anime_curve.linear,         _linear,  anime_curve_dir.normal     );
		_register(anime_curve.hold,           _hold,    anime_curve_dir.normal     );
		_register(anime_curve.quad_in,        _quad,    anime_curve_dir.normal     );
		_register(anime_curve.quad_out,       _quad,    anime_curve_dir.reverse    );
		_register(anime_curve.quad_in_out,    _quad,    anime_curve_dir.alternate  );
		_register(anime_curve.cubic_in,       _cubic,   anime_curve_dir.normal     );
		_register(anime_curve.cubic_out,      _cubic,   anime_curve_dir.reverse    );
		_register(anime_curve.cubic_in_out,   _cubic,   anime_curve_dir.alternate  );
		_register(anime_curve.quart_in,       _quart,   anime_curve_dir.normal     );
		_register(anime_curve.quart_out,      _quart,   anime_curve_dir.reverse    );
		_register(anime_curve.quart_in_out,   _quart,   anime_curve_dir.alternate  );
		_register(anime_curve.quint_in,       _quint,   anime_curve_dir.normal     );
		_register(anime_curve.quint_out,      _quint,   anime_curve_dir.reverse    );
		_register(anime_curve.quint_in_out,   _quint,   anime_curve_dir.alternate  );
		_register(anime_curve.expo_in,        _expo,    anime_curve_dir.normal     );
		_register(anime_curve.expo_out,       _expo,    anime_curve_dir.reverse    );
		_register(anime_curve.expo_in_out,    _expo,    anime_curve_dir.alternate  );
		_register(anime_curve.sine_in,        _sine,    anime_curve_dir.reverse    );
		_register(anime_curve.sine_out,       _sine,    anime_curve_dir.normal     );
		_register(anime_curve.sine_in_out,    _sine,    anime_curve_dir.alt_reverse);
		_register(anime_curve.circ_in,        _circ,    anime_curve_dir.normal     );
		_register(anime_curve.circ_out,       _circ,    anime_curve_dir.reverse    );
		_register(anime_curve.circ_in_out,    _circ,    anime_curve_dir.alternate  );
		_register(anime_curve.back_in,        _back,    anime_curve_dir.normal     );
		_register(anime_curve.back_out,       _back,    anime_curve_dir.reverse    );
		_register(anime_curve.back_in_out,    _back,    anime_curve_dir.alternate  );
		_register(anime_curve.elastic_in,     _elastic, anime_curve_dir.reverse    );
		_register(anime_curve.elastic_out,    _elastic, anime_curve_dir.normal     );
		_register(anime_curve.elastic_in_out, _elastic, anime_curve_dir.alt_reverse);
		_register(anime_curve.bounce_in,      _bounce,  anime_curve_dir.reverse    );
		_register(anime_curve.bounce_out,     _bounce,  anime_curve_dir.normal     );
		_register(anime_curve.bounce_in_out,  _bounce,  anime_curve_dir.alt_reverse);
		#endregion
	}
	static _global = new _class();
	return _global;
}

#endregion