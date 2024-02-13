#region char sprite map
function __char_sprite_map_state_create(sprite_map, state_name) {
	var struct = sprite_map.state[$ state_name];
	if (struct = undefined) {
		struct = {sprite: -1, delay: 0};
		sprite_map.state[$ state_name] = struct;
	}
	return struct;
}

function char_sprite_map_create() {
	return {
		defaultState : "",
		state : {}
	};
}

function char_sprite_map_default(sprite_map, default_state) {
	sprite_map.defaultState = default_state;
}

function char_sprite_map_1dir(sprite_map, state_name, sprite) {
	__char_sprite_map_state_create(sprite_map, state_name).sprite = [sprite];
}

function char_sprite_map_4dir(sprite_map, state_name, up, down, left, right) {
	__char_sprite_map_state_create(sprite_map, state_name).sprite = [right, down, left, up];
}

function char_sprite_map_8dir(sprite_map, state_name, right, up_right, up, up_left, left, down_left, down, down_right) {
	__char_sprite_map_state_create(sprite_map, state_name).sprite = [right, down_right, down, down_left, left, up_left, up, up_right];
}

function char_sprite_map_delay(sprite_map, state_name, frame_interval = infinity) {
	__char_sprite_map_state_create(sprite_map, state_name).delay = frame_interval;
}
#endregion



#region char sprite

#region create
function char_sprite_create(sprite_map, inst_id = id) {
	var defState = sprite_map.defaultState;
	return {
		parent : inst_id,
		stateMap : sprite_map,
		angle : 90,
		targetAngle : 90,
		state : defState,
		targetState : defState,
		stateStruct : sprite_map.state[$ defState],
		prevFrame : 0,
		delayFrame : 0
	};
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
function char_sprite_state(char_sprite, state_name_or_sprite) {
	char_sprite.targetState = state_name_or_sprite;
	char_sprite.delayFrame = char_sprite.prevFrame;
}

//change state after the set interval of frames finishes (defaults to previous state's delay)
function char_sprite_state_delay(char_sprite, state_name_or_sprite, frame_interval = -1) {
	char_sprite.targetState = state_name_or_sprite;
	
	if (frame_interval < 0) {
		var struct = char_sprite.stateStruct;
		frame_interval = (struct = undefined)? 0: struct.delay;
	}
	
	if (frame_interval = 0) {
		char_sprite.delayFrame = char_sprite.prevFrame;
		return;
	}
	if (frame_interval = infinity) {
		char_sprite.delayFrame = infinity;
		return;
	}
	char_sprite.delayFrame = (floor(char_sprite.prevFrame / frame_interval) + 1) * frame_interval;
}
#endregion

#region update sprite
function char_sprite_update(char_sprite) {
	var char = char_sprite;
	var par = char.parent;
	
	#region update state
	if (char.state != char.targetState) {
		if (par.image_number <= 1 || par.image_index >= char.delayFrame || par.image_index < char.prevFrame) {
			//state has changed
			char.state = char.targetState;
			char.stateStruct = char.stateMap.state[$ char.state];
			par.image_index = 0;
		}
	}
	char.prevFrame = par.image_index;
	
	if is_real(char.state) { //state is a sprite
		par.sprite_index = char.state;
		return;
	}
	#endregion
	
	#region update angle and sprite
	var state = char.stateStruct;
	if (state = undefined) {
		par.sprite_index = -1;
		return;
	}
	var sprite = state.sprite;
	if (!is_array(sprite)) {
		par.sprite_index = -1;
		return;
	}
	
	var num = array_length(sprite);
	if (num = 1) {
		char.angle = 0;
		par.sprite_index = sprite[0];
		return;
	}
	
	var angle = char.targetAngle * num / 360;
	var index = round(angle) % num;
	if ((index * 360 != char.angle * num) && abs(frac(angle) * 2 - 1) <= 0.2) {
		var midAng = (floor(angle) + 0.5) * 360 / num;
		index = ((midAng - char.angle + 360) % 360 < 180 ? floor(angle) : ceil(angle)) % num;
	}
	char.angle = index * 360 / num;
	par.sprite_index = sprite[index];
	#endregion
}
#endregion

#region extra
function char_sprite_reset(char_sprite) {
	var sprite_map = char_sprite.stateMap;
	var defState = sprite_map.defaultState;
	char_sprite.angle = 90;
	char_sprite.targetAngle = 90;
	char_sprite.state = defState;
	char_sprite.targetState = defState;
	char_sprite.stateStruct = sprite_map.state[$ defState];
	char_sprite.prevFrame = 0;
	char_sprite.delayFrame = 0;
}

function char_sprite_set_map(char_sprite, sprite_map) {
	var defState = sprite_map.defaultState;
	char_sprite.stateMap = sprite_map;
	char_sprite.state = defState;
	char_sprite.targetState = defState;
	char_sprite.stateStruct = sprite_map.state[$ defState];
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