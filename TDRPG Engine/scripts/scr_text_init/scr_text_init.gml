global.__text_data = {
	color : {},
	font : {},
	sound : {},
	command : {},
	silent : " \n\t",
	delay : {},
	gain : 1
}

#region in-text command functions
function __text_init_func(name_or_array, func) {
	__text_add_command_type(name_or_array, "init", func);
}

function __text_type_func(name_or_array, func) {
	__text_add_command_type(name_or_array, "type", func);
}

function __text_draw_func(name_or_array, func) {
	__text_add_command_type(name_or_array, "draw", func);
}

function __text_refresh_func(name_or_array, func) {
	__text_add_command_type(name_or_array, "refresh", func);
}

function __text_transform_effect(name_or_array, func_or_name) {
	__text_add_command_type(name_or_array, "transform", func_or_name);
}

function __text_render_effect(name_or_array, func) {
	__text_add_command_type(name_or_array, "render", func);
}

function __text_add_command_type(name_or_array, type, value) {
	static addCommand = function(name, type, value, removable) {
		var command = global.__text_data.command[$ name];
		if (command = undefined) {
			command = {removable: true};
			global.__text_data.command[$ name] = command;
		}
		command.removable &= removable; //a command is removable only if every type is removable
		command[$ type] = value;
	}
	
	var removable = (type = "variable" || type = "init");
	if is_array(name_or_array) {
		for (var i=0; i<array_length(name_or_array); i++) {
			addCommand(name_or_array[i], type, value, removable);
		}
	} else {
		addCommand(name_or_array, type, value, removable);
	}
}
#endregion

#region formatting
__text_draw_func(["color", "col", "c"], function(inst, param) {
	var col = global.__text_data.color[$ param[0]] ?? c_white;
	draw_set_color(col);
});

__text_draw_func(["/color", "/col", "/c"], function(inst) {
	draw_set_color(inst.defaultColor);
});

var fontFunc = function(inst, param) {
	var fn = global.__text_data.font[$ param[0]] ?? draw_get_font();
	draw_set_font(fn);
}
__text_draw_func("font", fontFunc);
__text_refresh_func("font", fontFunc);

var fontEndFunc = function(inst) {
	draw_set_font(inst.defaultFont);
}
__text_draw_func("/font", fontEndFunc);
__text_refresh_func("/font", fontEndFunc);
#endregion

#region typing options
__text_type_func(["sound", "snd"], function(inst, param) {
	inst.typeSound = global.__text_data.sound[$ param[0]];
});

__text_type_func(["/sound", "/snd"], function(inst) {
	inst.typeSound = inst.defaultTypeSound;
});

__text_type_func(["speed", "spd"], function(inst, param) {
	inst.typeSpeed = game_get_speed(gamespeed_fps) / real(param[0]);
});

__text_type_func(["/speed", "/spd"], function(inst) {
	inst.typeSpeed = inst.defaultTypeSpeed;
});
#endregion

#region transform effects
__text_transform_effect("shake", "shake");

__text_transform_effect("wave", "wave");

__text_transform_effect("scared", "scared");

__text_transform_effect(["/shake", "/wave", "/scared"], "reset");
#endregion

#region random
__text_type_func("wait", function(inst, param) {
	inst.wait_seconds(real(param[0]));
});

__text_draw_func(["sprite", "spr"], function(inst, param) {
	//TODO: make sprites react to angle
	var spr = asset_get_index(param[0]);
	if (spr = -1) return;
	with inst {
		var spd = sprite_get_speed(spr);
		if (sprite_get_speed_type(spr) = spritespeed_framespersecond) spd /= game_get_speed(gamespeed_fps);
		var subimg = (spd * frame) % sprite_get_number(spr);
		var w = sprite_get_width(spr) * drawXScale;
		var h = sprite_get_height(spr) * drawYScale;
		var _x = drawX + xx * drawXScale;
		var _y = drawY + yy * drawYScale + 0.5 * (lineHeight - h);
		draw_sprite_stretched(spr, subimg, _x, _y, w, h);
		xx += sprite_get_width(spr);
	}
});
__text_type_func(["sprite", "spr"], function(inst) {
	inst.wait(2);
	inst.play_type_sound();
});
__text_refresh_func(["sprite", "spr"], function(inst, param) {
	var spr = asset_get_index(param[0]);
	if (spr = -1) return;
	inst.wordWidth += sprite_get_width(spr);
})
#endregion