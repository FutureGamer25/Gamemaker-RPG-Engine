//feather ignore all

///@desc	Creates a new animation with a starting position. Use the built-in methods to edit and run the animation.
///@param {Real} start_val		The first value of the animation
///@return {Struct.__anime_class}
function create_anime(_start_val) {
	return new __anime_class(_start_val);
}

///@desc	Animates a value between two positions along a single curve.
///			For built-in easing set ease_type to a string, or for custom easing use a function,
///			animation curve struct or ID, or animation curve channel.
///@param {Real} val1				The first value of the animation
///@param {Real} val2				The last value of the animation
///@param {Real} frames				The duration in frames
///@param {String|Function|Struct|Asset.GMAnimCurve} ease_type
///									The easing curve
///@param {Function} call_method	The method to call for each frame of animation
///@return {Struct.__anime_class}
function do_anime(_val1, _val2, _frames, _ease_type, _call_method) {
	return create_anime(_val1).add(_val2, _frames, _ease_type).start(_call_method);
}

///@ignore
function __anime_class(_def_val, _def_loop = false, _def_func = undefined, _def_data = []) constructor {
	///@desc	Adds a new position to the animation.
	///			For built-in easing set ease_type to a string, or for custom easing use a function,
	///			animation curve struct or ID, or animation curve channel.
	///@param {Real} val		The value to animate to
	///@param {Real} frames		The duration in frames to arrive at the value
	///@param {String|Function|Struct|Asset.GMAnimCurve} [ease_type]
	///							The easing curve (defaults to "linear")
	///@return {Struct.__anime_class}
	static add = function(_val, _frames, _ease_type = "linear") {
		if (_frames < 1) {
			show_message("ANIME: Frames cannot be less than 1.");
			return self;
		}
		
		var _mode = 0;
		
		#region get ease info
		if is_string(_ease_type) {
			_mode = 0;
		} else if is_callable(_ease_type) {
			_mode = 1;
			if (!is_method(_ease_type)) {
				_ease_type = method(other, _ease_type);
			}
		} else if is_handle(_ease_type) { //animcurve
			if (asset_get_type(_ease_type) = asset_animationcurve) {
				_mode = 2;
				_ease_type = _get_channel(animcurve_get(_ease_type));
				if (_ease_type = undefined) return self;
			}
		} else if is_struct(_ease_type) { //animcurve or channel
			_mode = 2;
			if animcurve_exists(_ease_type) {
				_ease_type = _get_channel(_ease_type);
				if (_ease_type = undefined) return self;
			}
		}
		#endregion
		
		array_push(_data, {
			_val: _val,
			_frames: _frames,
			_ease: _ease_type,
			_mode: _mode
		});
		return self;
	}
	
	///@desc	Enables or disables looping. Use stop() to exit looping animations.
	///@param {Bool} [do_loop]	Whether to loop (defaults to true)
	///@return {Struct.__anime_class}
	static loop = function(_do_loop = true) {
		self._do_loop = _do_loop;
		return self;
	}
	
	///@desc	Sets the call method. In most cases this is not needed as one can be set with start()
	///@param {Function} call_method	The method to call for each frame of animation
	///@return {Struct.__anime_class}
	static set_method = function(_call_method) {
		_func = _call_method;
		return self;
	}
	
	///@desc	Starts the animation (or unpauses if previously paused).
	///@param {Function} [call_method]	Optionally set the call method if one was not set previously
	///@return {Struct.__anime_class}
	static start = function(_call_method = _func) {
		_func = _call_method;
		if (!is_method(_func)) {
			show_message("ANIME: Cannot start without call method.");
			return self;
		}
		if (array_length(_data) = 0) return self;
		if (_index = -1) { //not paused
			_x2 = _x_start;
			_next_data();
		}
		if (_time_source = -1) {
			_time_source = call_later(1, time_source_units_frames, _callback, true);
		}
		return self;
	}
	
	///@desc	Pauses the animation. Use start() to unpause.
	///@return {Struct.__anime_class}
	static pause = function() {
		if (_time_source != -1) {
			call_cancel(_time_source);
			_time_source = -1;
		}
		return self;
	}
	
	///@desc	Stops the animation.
	///@return {Struct.__anime_class}
	static stop = function() {
		if (_time_source != -1) {
			call_cancel(_time_source);
			_time_source = -1;
		}
		_index = -1;
		return self;
	}
	
	///@desc	Returns a duplicate copy of the animation. Useful for running multiple of an animation simultaneously.
	///@return {Struct.__anime_class}
	static clone = function() {
		var _len = array_length(_data);
		var _new_data = array_create(_len);
		array_copy(_new_data, 0, _data, 0, _len);
		return new __anime_class(_x_start, _do_loop, _func, _new_data);
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
		_ease = _dat._ease;
		_mode = _dat._mode;
		return true;
	}
	
	/**@ignore*/ _callback = function() {
		_frame ++;
		var _val = _frame / _max_frames;
		var _amount;
		if (_mode = 0) { //string
			_amount = lerp_type(_x1, _x2, _val, _ease);
		} else if (_mode = 1) { //method
			_amount = (_x2 - _x1) * _ease(_val) + _x1;
		} else { //animcurve channel
			_amount = (_x2 - _x1) * animcurve_channel_evaluate(_ease, _val) + _x1;
		}
		if is_method(_func) _func(_amount);
		if (_val >= 1) {
			if (!_next_data()) stop();
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
	
	/**@ignore*/ _time_source = -1;
	/**@ignore*/ _index = -1;
	/**@ignore*/ _x1 = _def_val;
	/**@ignore*/ _x2 = _def_val;
	/**@ignore*/ _frame = 0;
	/**@ignore*/ _max_frames = 1;
	/**@ignore*/ _ease = "";
	/**@ignore*/ _mode = undefined;
}