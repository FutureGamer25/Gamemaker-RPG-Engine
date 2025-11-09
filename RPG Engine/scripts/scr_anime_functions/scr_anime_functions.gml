//feather ignore all

///@desc	Creates a new animation with a starting position. Use the built-in methods to edit and run the animation.
///@param {Real} start_val		The first value of the animation
///@return {Struct.__anime_class}
function create_anime(_start_val) {
	return new __anime_class(_start_val);
}

///@desc	Animates a value between two positions along a single curve.
///			NOTE: For built-in easing curves use anime_curve.[curve name]
///			For custom curves use a function, animation curve, or animation curve channel.
///@param {Real} val1				The first value of the animation
///@param {Real} val2				The last value of the animation
///@param {Real} frames				The duration in frames
///@param {Real|Function|Struct|Asset.GMAnimCurve} easing_curve
///									The easing curve
///@param {Function} call_method	The method to call for each frame of animation
///@return {Struct.__anime_class}
function do_anime(_val1, _val2, _frames, _easing_curve, _call_method) {
	return create_anime(_val1)._add(_val2, _frames, _easing_curve)._set_method(_call_method)._start();
}

///@ignore
function __anime_class(_def_val, _def_func = undefined, _def_loop = false, _def_data = []) constructor {
	///@desc	Adds a new position to the animation.
	///			NOTE: For built-in easing curves use anime_curve.[curve name]
	///			For custom curves use a function, animation curve, or animation curve channel.
	///@param {Real} val		The value to animate to
	///@param {Real} frames		The duration in frames to arrive at the value
	///@param {Real|Function|Struct|Asset.GMAnimCurve} [easing_curve]
	///							The easing curve (defaults to "linear")
	///@return {Struct.__anime_class}
	static _add = function(_val, _frames, _easing_curve = anime_curve.linear) {
		if (_frames < 1) {
			show_message("ANIME: Frames cannot be less than 1.");
			return self;
		}
		
		var _mode = 0;
		
		#region get ease info
		if is_real(_easing_curve) {
			_mode = 0;
		} else if is_callable(_easing_curve) {
			_mode = 1;
			if (!is_method(_easing_curve)) {
				_easing_curve = method(other, _easing_curve);
			}
		} else if is_handle(_easing_curve) { //animcurve
			if (asset_get_type(_easing_curve) = asset_animationcurve) {
				_mode = 2;
				_easing_curve = _get_channel(animcurve_get(_easing_curve));
				if (_easing_curve = undefined) return self;
			}
		} else if is_struct(_easing_curve) { //animcurve or channel
			_mode = 2;
			if animcurve_exists(_easing_curve) {
				_easing_curve = _get_channel(_easing_curve);
				if (_easing_curve = undefined) return self;
			}
		}
		#endregion
		
		array_push(_data, {
			_val: _val,
			_frames: _frames,
			_easing_curve: _easing_curve,
			_mode: _mode
		});
		return self;
	}
	
	///@desc	Enables or disables looping. Use _stop() to exit looping animations.
	///@param {Bool} [do_loop]	Whether to loop (defaults to true)
	///@return {Struct.__anime_class}
	static _loop = function(_do_loop = true) {
		self._do_loop = _do_loop;
		return self;
	}
	
	///@desc	Sets the callback method.
	///@param {Function} call_method	The method to call for each frame of animation
	///@return {Struct.__anime_class}
	static _set_method = function(_call_method) {
		_func = _call_method;
		return self;
	}
	
	/**@ignore*/ static _set_time_units = function(_time_units) {
		self._time_units = _time_units;
	}
	
	///@desc	Starts the animation.
	///@return {Struct.__anime_class}
	static _start = function() {
		_state = anime_state_active;
		if (array_length(_data) = 0) return self;
		_index = -1;
		_x2 = _x_start;
		_next_data();
		if (_time_source = undefined) {
			_time_source = call_later(1, time_source_units_frames, _callback, true);
		}
		return self;
	}
	
	///@desc	Stops the animation.
	///@return {Struct.__anime_class}
	static _stop = function() {
		_state = anime_state_stopped;
		if (_time_source != undefined) {
			call_cancel(_time_source);
			_time_source = undefined;
		}
		return self;
	}
	
	///@desc	Pauses the animation.
	///@return {Struct.__anime_class}
	static _pause = function() {
		if (_state != anime_state_active) return self;
		_state = anime_state_paused;
		if (_time_source != undefined) {
			call_cancel(_time_source);
			_time_source = undefined;
		}
		return self;
	}
	
	///@desc	Resumes the animation.
	///@return {Struct.__anime_class}
	static _resume = function() {
		if (_state != anime_state_paused) return self;
		_state = anime_state_active;
		if (_time_source = undefined) {
			_time_source = call_later(1, time_source_units_frames, _callback, true);
		}
		return self;
	}
	
	///@desc	Returns a duplicate copy of the animation. Useful for running multiple of an animation simultaneously.
	///@return {Struct.__anime_class}
	//static _clone = function() {
	//	var _len = array_length(_data);
	//	var _new_data = array_create(_len);
	//	array_copy(_new_data, 0, _data, 0, _len);
	//	return new __anime_class(_x_start, _func, _do_loop, _new_data);
	//}
	static _clone = function() { //new system doesn't need to copy the array
		return new __anime_class(_x_start, _func, _do_loop, _data);
	}
	
	/**@ignore*/ static _next_data = function() {
		_index ++;
		if (_index >= array_length(_data)) {
			if _do_loop {
				_index = 0;
				_x2 = _x_start;
			} else {
				return false;
			}
		}
		var _dat = _data[_index];
		_x1 = _x2;
		_x2 = _dat._val;
		_frame = 0;
		_max_frames = _dat._frames;
		_easing_curve = _dat._easing_curve;
		_mode = _dat._mode;
		return true;
	}
	
	/**@ignore*/ _callback = function() {
		_frame ++;
		var _val = _frame / _max_frames;
		var _amount;
		if (_mode = 0) { //string
			_amount = anime_curve_lerp(_x1, _x2, _val, _easing_curve);
		} else if (_mode = 1) { //method
			_amount = (_x2 - _x1) * _easing_curve(_val) + _x1;
		} else { //animcurve channel
			_amount = (_x2 - _x1) * animcurve_channel_evaluate(_easing_curve, _val) + _x1;
		}
		if is_method(_func) _func(_amount);
		if (_val >= 1) {
			if (!_next_data()) _stop();
		}
	}
	
	/**@ignore*/ static _get_channel = function(animcurve) {
		if (array_length(animcurve.channels) <= 0) {
			show_message("ANIME: Animation curves must have at least one channel.");
			return undefined;
		}
		return animcurve_get_channel(animcurve, 0);
	}
	
	/**@ignore*/ _x_start = _def_val;
	/**@ignore*/ _do_loop = _def_loop;
	/**@ignore*/ _func = _def_func;
	/**@ignore*/ _data = _def_data;
	
	/**@ignore*/ _state = anime_state_initial;
	/**@ignore*/ _time_source = undefined;
	/**@ignore*/ _time_units = anime_units_frames;
	/**@ignore*/ _index = -1;
	/**@ignore*/ _x1 = _def_val;
	/**@ignore*/ _x2 = _def_val;
	/**@ignore*/ _frame = 0;
	/**@ignore*/ _max_frames = 1;
	/**@ignore*/ _easing_curve = "";
	/**@ignore*/ _mode = undefined;
}