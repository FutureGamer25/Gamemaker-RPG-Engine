//feather disable all

///@return {Struct.__anime_class}
function create_anime(start_val) {
	return new __anime_class(start_val);
}

///@return {Struct.__anime_class}
function do_anime(val1, val2, frames, ease_type, call_method) {
	return create_anime(val1).add(val2, frames, ease_type).start(call_method);
}

///@ignore
function __anime_class(start_val) constructor {
	///@return {Struct.__anime_class}
	static add = function(val, frames, ease_type = "linear") {
		if (frames < 1) {
			show_message("ANIME: Frames cannot be less than 1.")
			return self;
		}
		array_push(data, {
			val : val,
			frames : frames,
			type :  ease_type
		});
		return self;
	}
	
	///@return {Struct.__anime_class}
	static loop = function(_loop = true) {
		doLoop = _loop;
		return self;
	}
	
	///@return {Struct.__anime_class}
	static start = function(call_method = func) {
		if (array_length(data) = 0) return self;
		index = -1;
		x2 = xStart;
		nextData();
		func = call_method;
		if (!is_method(func)) {
			show_message("ANIME: Cannot start without call method.");
			return self;
		}
		stop();
		timeSource = call_later(1, time_source_units_frames, callback, true);
		return self;
	}
	
	///@return {Struct.__anime_class}
	static stop = function() {
		if (timeSource != -1) {
			call_cancel(timeSource);
			timeSource = -1;
		}
		return self;
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
		type = dat.type;
		return true;
	}
	
	/**@ignore*/ callback = function() {
		frame ++;
		var val = frame / maxFrames;
		if is_method(func) func(lerp_type(x1, x2, val, type));
		if (val >= 1) {
			if (!nextData()) stop();
		}
	}
	
	/**@ignore*/ xStart = start_val;
	/**@ignore*/ x1 = start_val;
	/**@ignore*/ x2 = start_val;
	/**@ignore*/ frame = 0;
	/**@ignore*/ maxFrames = 1;
	/**@ignore*/ type = "";
	/**@ignore*/ func = undefined;
	/**@ignore*/ doLoop = false;
	
	/**@ignore*/ data = [];
	/**@ignore*/ index = -1;
	/**@ignore*/ timeSource = -1;
}