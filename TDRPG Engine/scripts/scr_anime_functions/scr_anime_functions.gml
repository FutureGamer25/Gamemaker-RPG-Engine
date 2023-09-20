//eather disable all
//inconsistent errors showing up
function create_anime(start_val) {
	var a = new __anime_class(start_val);
	a.id = weak_ref_create(a);
	return a;
}

function do_anime(val1, val2, frames, ease_type, call_method) {
	return create_anime(val1).add(val2, frames, ease_type).start(call_method);
}

function __anime_class(start_val) constructor {
	static add = function(val, frames, ease_type = "linear") {
		if (frames < 1) {
			show_message("ANIME: Frames cannot be less than 1.")
			return id.ref;
		}
		array_push(data, {
			val : val,
			frames : frames,
			type :  ease_type
		});
		return id.ref;
	}
	
	static loop = function(_loop = true) {
		doLoop = _loop;
		return id.ref;
	}
	
	static start = function(call_method = func) {
		if (array_length(data) = 0) return id.ref;
		index = -1;
		x2 = xStart;
		nextData();
		func = call_method;
		if (!is_method(func)) {
			show_message("ANIME: Cannot start without call method.");
			return id.ref;
		}
		stop();
		timeSource = call_later(1, time_source_units_frames, callback, true);
		return id.ref;
	}
	
	static stop = function() {
		if (timeSource != -1) {
			call_cancel(timeSource);
			timeSource = -1;
		}
		return id.ref;
	}
	
	static nextData = function() {
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
	
	callback = function() {
		frame ++;
		var val = frame / maxFrames;
		if is_method(func) func(lerp_type(x1, x2, val, type));
		if (val >= 1) {
			if (!nextData()) stop();
		}
	}
	
	xStart = start_val;
	x1 = start_val;
	x2 = start_val;
	frame = 0;
	maxFrames = 1;
	type = "";
	func = -1;
	doLoop = false;
	
	data = [];
	index = -1;
	timeSource = -1;
	id = -1;
}