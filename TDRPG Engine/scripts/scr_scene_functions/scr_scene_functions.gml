#region add functions
function scene_func(func, param_array = undefined) {
	static data = __cutscene_get_data();
	
	if !is_method(func) func = method(self, func);
	with data.current.currentThread {
		array_push(funcArr, func);
		array_push(paramArr, param_array);
		array_push(skipArr, true);
		array_push(breakArr, false);
	}
}

function scene_func_repeat(func, param_array = undefined) {
	scene_func(func, param_array);
	scene_set_skip(false);
	scene_set_break(true);
}

function scene_method(struct_or_instance, func, param_array = undefined) {
	scene_func(method(struct_or_instance, func), param_array);
}

function scene_method_repeat(struct_or_instance, func, param_array = undefined) {
	scene_func_repeat(method(struct_or_instance, func), param_array);
}

function scene_preset(param_array, create_func, step_func) {
	var struct = {};
	scene_method(struct, create_func, param_array);
	scene_method_repeat(struct, step_func);
}
#endregion

#region function types
function scene_set_skip(do_auto_skip) {
	with __cutscene_get_data().current.currentThread skipArr[array_length(skipArr) - 1] = do_auto_skip;
}

function scene_set_break(do_break) {
	with __cutscene_get_data().current.currentThread breakArr[array_length(breakArr) - 1] = do_break;
}
#endregion

///@function scene_struct_set(struct,name_1,val_1,...)
function scene_struct_set(struct, name, val) {
	/*for (var i=1; i<argument_count-1; i+=2) {
		scene_func(variable_struct_set, [struct, argument[i], argument[i + 1]]);
	}*/
	if (argument_count > 3) {
		
		var arr = []
		for (var i=argument_count-1; i>=0; i--) arr[i] = argument[i];
		
		scene_func(function(struct) {
			for (var i=1; i<argument_count-1; i+=2) {
				struct[$ argument[i]] = argument[i + 1];
			}
		}, arr);
		
	} else {
		scene_func(variable_struct_set, [struct, name, val]);
	}
}

function scene_label(label_name) {
	with __cutscene_get_data().current.currentThread labels[$ label_name] = array_length(funcArr);
}

function scene_goto(label_name) {
	scene_method(__cutscene_get_data().current.currentThread, function(name) {
		var index = labels[$ name];
		if (index = undefined) {
			show_message("No label in currrent branch with the name \""+name+"\"");
			exit;
		}
		sceneIndex = index;
	}, [label_name]);
	scene_set_skip(false);
}

function scene_goto_if(label_name, condition_func) {
	scene_method(__cutscene_get_data().current.currentThread, function(name, func) {
		if func() {
			var index = labels[$ name];
			if (index = undefined) {
				show_message("No label in currrent branch with the name \""+name+"\"");
				exit;
			}
			sceneIndex = index;
		} else {
			sceneIndex ++;
		}
	}, [label_name, condition_func]);
	scene_set_skip(false);
}

#region branches
function scene_branch_start() {
	var thread = undefined;
	with __cutscene_get_data().current {
		useThreads = true;
		thread = newThread();
		
		scene_func(function(thread) {
			thread.sceneIndex = 0;
			playThread(thread);
		}, [thread]);
		
		currentThread = thread;
		array_push(threadStack, thread);
	}
	return thread;
}

function scene_branch_add() {
	scene_branch_end();
	return scene_branch_start();
}

function scene_branch_end() {
	with __cutscene_get_data().current {
		array_pop(threadStack);
		currentThread = array_last(threadStack);
	}
}

function scene_branch_pause(branch) {
	scene_func(function(branch) {
		branch.paused = true;
	}, [branch]);
}
#endregion

#region threads
function scene_thread_start() {
	scene_method(cutscene_thread(), function() {threadCount = 1;});
	return scene_branch_start();
}

function scene_thread_add() {
	with __cutscene_get_data().current {
		var parentThread = threadStack[array_length(threadStack) - 2];
		scene_func(function(thread) {
			thread.threadCount --;
			if (thread.threadCount <= 0) {
				playThread(thread);
			}
		}, [parentThread]);
	}
	
	scene_branch_end();
	
	scene_method(cutscene_thread(), function() {threadCount ++;});
	return scene_branch_start();
}

function scene_thread_end() {
	with __cutscene_get_data().current {
		var parentThread = threadStack[array_length(threadStack) - 2];
		scene_func(function(thread) {
			thread.threadCount --;
			if (thread.threadCount <= 0) {
				playThread(thread);
			}
		}, [parentThread]);
	}
	
	scene_branch_end();
	
	scene_method(cutscene_thread(), function() {
		paused = true;
	});
	scene_set_break(true);
}

function scene_thread_pause(thread) {
	scene_branch_pause(thread);
}
#endregion

function scene_wait(frames) {
	var struct = {};
	scene_struct_set(struct, "frame", frames);
	
	scene_method_repeat(struct, function() {
		if (frame <= 0) cutscene_skip();
		frame --;
	});
}

function scene_lerp_func(x1, x2, frames, ease_type, func) {
	if (!is_method(func)) func = method(self, func);
	
	static create = function(_x1, _x2, _frames, _type, _func) {
		x1 = _x1;
		x2 = _x2;
		frame = 0;
		frameMax = _frames;
		type = _type;
		func = _func;
	}
	
	static step = function() {
		var val = frame / frameMax;
		if (val >= 1) {
			val = 1;
			cutscene_skip();
		}
		func(lerp_type(x1, x2, val, type));
		frame ++;
	}
	
	scene_preset([x1, x2, frames, ease_type, func], create, step);
}

#region objects
function scene_set_pos(_id, _x, _y) {
	scene_func(function(_id, _x, _y) {
		_id.x = _x;
		_id.y = _y;
	}, [_id, _x, _y]);
}

function scene_move_time(_id, _x, _y, frames) {
	static create = function(_id, _x, _y, _frames) {
		inst = _id;
		oldX = inst.x;
		oldY = inst.y;
		distX = _x - oldX;
		distY = _y - oldY;
		frames = _frames;
		pos = 0;
	}
	
	static step = function() {
		if (pos < frames) {
			pos += 1;
			var percent = pos / frames;
			inst.x = oldX + distX * percent;
			inst.y = oldY + distY * percent;
		} else {
			inst.x = distX + oldX;
			inst.y = distY + oldY;
			cutscene_skip();
		}
	}
	
	scene_preset([_id, _x, _y, frames], create, step);
}

function scene_move_speed(_id, _x, _y, _speed) {
	static create = function(_id, _x, _y, _speed) {
		inst = _id;
		oldX = inst.x;
		oldY = inst.y;
		distX = _x - oldX;
		distY = _y - oldY;
		dist = sqrt( sqr(distX) + sqr(distY) );
		spd = _speed
		pos = 0;
	}
	
	static step = function() {
		if (pos < dist) {
			pos += spd;
			var percent = pos / dist;
			inst.x = oldX + distX * percent;
			inst.y = oldY + distY * percent;
		} else {
			inst.x = distX + oldX;
			inst.y = distY + oldY;
			cutscene_skip();
		}
	}
	
	scene_preset([_id, _x, _y, _speed], create, step);
}

function scene_set_sprite(_id, _sprite) {
	scene_func(variable_instance_set, [_id, "sprite_index", _sprite]);
}
#endregion