//feather disable all

///@desc	Creates a new animation with a starting position. Use the built-in methods to edit and run the animation.
///@param {Real} start_val		The first value of the animation
///@return {Struct.__anime_class}
function create_anime(start_val) {
	return new __anime_class(start_val);
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
function do_anime(val1, val2, frames, ease_type, call_method) {
	return create_anime(val1).add(val2, frames, ease_type).start(call_method);
}

///@ignore
function __anime_class(def_val, def_loop = false, def_func = undefined, def_data = []) constructor {
	///@desc	Adds a new position to the animation.
	///			For built-in easing set ease_type to a string, or for custom easing use a function,
	///			animation curve struct or ID, or animation curve channel.
	///@param {Real} val		The value to animate to
	///@param {Real} frames		The duration in frames to arrive at the value
	///@param {String|Function|Struct|Asset.GMAnimCurve} [ease_type]
	///							The easing curve (defaults to "linear")
	///@return {Struct.__anime_class}
	static add = function(val, frames, ease_type = "linear") {
		if (frames < 1) {
			show_message("ANIME: Frames cannot be less than 1.")
			return self;
		}
		
		var _mode = 0;
		
		#region get ease info
		if is_string(ease_type) {
			_mode = 0;
		} else if is_callable(ease_type) {
			_mode = 1;
			if (!is_method(ease_type)) {
				ease_type = method(other, ease_type);
			}
		} else if is_handle(ease_type) { //animcurve
			if (asset_get_type(ease_type) = asset_animationcurve) {
				_mode = 2;
				ease_type = getChannel(animcurve_get(ease_type));
				if (ease_type = undefined) return self;
			}
		} else if is_struct(ease_type) { //animcurve or channel
			_mode = 2;
			if animcurve_exists(ease_type) {
				ease_type = getChannel(ease_type);
				if (ease_type = undefined) return self;
			}
		}
		#endregion
		
		array_push(data, {
			val: val,
			frames: frames,
			ease: ease_type,
			mode: _mode
		});
		return self;
	}
	
	///@desc	Enables or disables looping. Use stop() to exit looping animations.
	///@param {Bool} [do_loop]	Whether to loop (defaults to true)
	///@return {Struct.__anime_class}
	static loop = function(do_loop = true) {
		doLoop = do_loop;
		return self;
	}
	
	///@desc	Sets the call method. In most cases this is not needed as one can be set with start()
	///@param {Function} call_method	The method to call for each frame of animation
	///@return {Struct.__anime_class}
	static set_method = function(call_method) {
		func = call_method;
		return self;
	}
	
	///@desc	Starts the animation (or unpauses if previously paused).
	///@param {Function} [call_method]	Optionally set the call method if one was not set previously
	///@return {Struct.__anime_class}
	static start = function(call_method = func) {
		func = call_method;
		if (!is_method(func)) {
			show_message("ANIME: Cannot start without call method.");
			return self;
		}
		if (array_length(data) = 0) return self;
		if (index = -1) { //not paused
			x2 = xStart;
			nextData();
		}
		if (timeSource = -1) {
			timeSource = call_later(1, time_source_units_frames, callback, true);
		}
		return self;
	}
	
	///@desc	Pauses the animation. Use start() to unpause.
	///@return {Struct.__anime_class}
	static pause = function() {
		if (timeSource != -1) {
			call_cancel(timeSource);
			timeSource = -1;
		}
		return self;
	}
	
	///@desc	Stops the animation.
	///@return {Struct.__anime_class}
	static stop = function() {
		if (timeSource != -1) {
			call_cancel(timeSource);
			timeSource = -1;
		}
		index = -1;
		return self;
	}
	
	///@desc	Returns a duplicate copy of the animation. Useful for running multiple of an animation simultaneously.
	///@return {Struct.__anime_class}
	static clone = function() {
		var len = array_length(data);
		var newData = array_create(len);
		array_copy(newData, 0, data, 0, len);
		return new __anime_class(xStart, doLoop, func, newData);
	}
	
	/**@ignore*/ static nextData = function() {
		index ++;
		if (index >= array_length(data)) {
			if doLoop {
				index = 0;
				x2 = xStart;
			} else {
				return false;
			}
		}
		var dat = data[index];
		x1 = x2;
		x2 = dat.val;
		frame = 0;
		maxFrames = dat.frames;
		ease = dat.ease;
		mode = dat.mode;
		return true;
	}
	
	/**@ignore*/ callback = function() {
		frame ++;
		var val = frame / maxFrames;
		var amount;
		if (mode = 0) { //string
			amount = lerp_type(x1, x2, val, ease);
		} else if (mode = 1) { //method
			amount = (x2 - x1) * ease(val) + x1;
		} else { //animcurve channel
			amount = (x2 - x1) * animcurve_channel_evaluate(ease, val) + x1;
		}
		if is_method(func) func(amount);
		if (val >= 1) {
			if (!nextData()) stop();
		}
	}
	
	/**@ignore*/ static getChannel = function(animcurve) {
		if (array_length(animcurve.channels) <= 0) {
			show_message("ANIME: Animation curves must have at least one channel.");
			return undefined;
		}
		return animcurve_get_channel(animcurve, 0);
	}
	
	/**@ignore*/ xStart = def_val;
	/**@ignore*/ doLoop = def_loop;
	/**@ignore*/ func = def_func;
	/**@ignore*/ data = def_data;
	
	/**@ignore*/ timeSource = -1;
	/**@ignore*/ index = -1;
	/**@ignore*/ x1 = def_val;
	/**@ignore*/ x2 = def_val;
	/**@ignore*/ frame = 0;
	/**@ignore*/ maxFrames = 1;
	/**@ignore*/ ease = "";
	/**@ignore*/ mode = undefined;
}