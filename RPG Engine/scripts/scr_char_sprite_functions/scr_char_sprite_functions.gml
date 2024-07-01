#region char sprite map
///@ignore
function __char_sprite_map_class() constructor {
	defaultState = "";
	state = {};
	
	static create_state = function(state_name) {
		var struct = state[$ state_name];
		if (struct = undefined) {
			struct = {sprite: -1, delay: 1};
			state[$ state_name] = struct;
		}
		return struct;
	}
	static get_state = function(state_name) {
		return state[$ state_name];
	}
}

function char_sprite_map_create() {
	return new __char_sprite_map_class();
}

function char_sprite_map_default(sprite_map, default_state) {
	sprite_map.defaultState = default_state;
}

function char_sprite_map_1dir(sprite_map, state_name, sprite) {
	sprite_map.create_state(state_name).sprite = [sprite];
}

function char_sprite_map_4dir(sprite_map, state_name, up, down, left, right) {
	sprite_map.create_state(state_name).sprite = [right, down, left, up];
}

function char_sprite_map_8dir(sprite_map, state_name, right, up_right, up, up_left, left, down_left, down, down_right) {
	sprite_map.create_state(state_name).sprite = [right, down_right, down, down_left, left, up_left, up, up_right];
}

function char_sprite_map_delay(sprite_map, state_name, frame_interval = infinity) {
	sprite_map.create_state(state_name).delay = frame_interval;
}
#endregion



#region char sprite

#region create
///@ignore
function __char_sprite_class(sprite_map, inst_id) constructor {
	static init = function() {
		angle = 90;
		targetAngle = 90;
		prevFrame = 0;
		var defState = stateMap.defaultState;
		state = defState;
		
		//state params
		targetState = defState;
		delayFrame = 0;
		initFrame = 0;
		delayCallback = undefined;
		
		refresh_state();
	}
	static refresh_state = function() {
		stateStruct = stateMap.get_state(state);
	}
	
	static set_state = function(state, index, delay, callback) {
		targetState = state;
		initFrame = index;
		delayCallback = callback;
		if (delay <= 0) {
			delayFrame = prevFrame;
			return;
		}
		if (delay = infinity) {
			delayFrame = infinity;
			return;
		}
		delayFrame = (floor(prevFrame / delay) + 1) * delay;
	}
	static get_delay = function() {
		return (stateStruct = undefined)? 0: stateStruct.delay;
	}
	
	parent = inst_id;
	stateMap = sprite_map;
	init();
}

function char_sprite_create(sprite_map, inst_id = id) {
	return new __char_sprite_class(sprite_map, inst_id);
}
#endregion

#region set direction
function char_sprite_dir(char_sprite, dir_x, dir_y) {
	if (dir_x = 0 && dir_y = 0) return;
	char_sprite.targetAngle = darctan2(dir_y, dir_x) + 360;
}

function char_sprite_angle(char_sprite, degrees) {
	char_sprite.targetAngle = 360 - (degrees % 360);
}
#endregion

#region set state
function char_sprite_state(char_sprite, state_name_or_sprite, callback = undefined) {
	char_sprite.set_state(state_name_or_sprite, 0, 0, callback);
}

function char_sprite_state_sync(char_sprite, state_name_or_sprite, callback = undefined) {
	char_sprite.set_state(state_name_or_sprite, undefined, 0, callback);
}

//change state at the interval given by the previous state
function char_sprite_state_delay(char_sprite, state_name_or_sprite, callback = undefined) {
	char_sprite.set_state(state_name_or_sprite, 0, char_sprite.get_delay(), callback);
}

//change state at the set frame interval
function char_sprite_state_delay_frames(char_sprite, state_name_or_sprite, delay_frames, callback = undefined) {
	char_sprite.set_state(state_name_or_sprite, 0, delay_frames, callback);
}

function char_sprite_state_ext(char_sprite, state_name_or_sprite, params) {
	static syncHash = variable_get_hash("sync");
	static indexHash = variable_get_hash("image_index");
	static delayHash = variable_get_hash("delay");
	static framesHash = variable_get_hash("delay_frames");
	static callbackHash = variable_get_hash("callback");
	
	var index;
	if (struct_get_from_hash(params, syncHash) ?? false) {
		index = undefined;
	} else {
		index = struct_get_from_hash(params, indexHash) ?? 0;
	}
	var delay = struct_get_from_hash(params, framesHash);
	if (delay = undefined) {
		if (struct_get_from_hash(params, delayHash) ?? false) {
			delay = char_sprite.get_delay();
		} else {
			delay = 0;
		}
	}
	var callback = struct_get_from_hash(params, callbackHash);
	
	char_sprite.set_state(state_name_or_sprite, index, delay, callback);
}
#endregion

#region update sprite
function char_sprite_update(char_sprite) {
	var char = char_sprite;
	var par = char.parent;
	
	#region update state
	var prev = char.prevFrame;
	char.prevFrame = par.image_index;
	if (char.state != char.targetState) {
		if (par.image_number <= 1 || par.image_index >= char.delayFrame || par.image_index < prev) {
			//state has changed
			char.state = char.targetState;
			char.stateStruct = char.stateMap.get_state(char.state);
			var initFrame = char.initFrame;
			if is_real(initFrame) par.image_index = initFrame;
			if is_method(char.delayCallback) char.delayCallback();
		}
	}
	
	if is_real(char.state) { //state is a sprite
		par.sprite_index = char.state;
		return;
	}
	#endregion
	
	#region update angle and sprite
	static getSprite = function(spriteData) {
		if is_struct(spriteData) return spriteData.sprite_index;
		return spriteData;
	}
	
	var state = char.stateStruct;
	if (state = undefined) {
		par.sprite_index = -1;
		return;
	}
	var spriteArr = state.sprite;
	if (!is_array(spriteArr)) {
		par.sprite_index = -1;
		return;
	}
	
	var num = array_length(spriteArr);
	var index = 0;
	if (num > 1) {
		var angle = char.targetAngle * num / 360;
		index = round(angle) % num;
		if ((index * 360 != char.angle * num) && abs(frac(angle) * 2 - 1) <= 0.2) {
			var midAng = (floor(angle) + 0.5) * 360 / num;
			index = ((midAng - char.angle + 360) % 360 < 180 ? floor(angle) : ceil(angle)) % num;
		}
	}
	char.angle = index * 360 / num;
	par.sprite_index = getSprite(spriteArr[index]);
	#endregion
}
#endregion

#region extra
function char_sprite_reset(char_sprite) {
	char_sprite.init();
}

function char_sprite_set_map(char_sprite, sprite_map) {
	char_sprite.stateMap = sprite_map;
	char_sprite.refresh_state();
}

function char_sprite_get_state(char_sprite) {
	return char_sprite.state;
}

function char_sprite_get_x(char_sprite) {
	return dcos(char_sprite.angle);
}

function char_sprite_get_y(char_sprite) {
	return dsin(char_sprite.angle);
}

function char_sprite_get_angle(char_sprite) {
	return 360 - char_sprite.angle;
}
#endregion

#endregion