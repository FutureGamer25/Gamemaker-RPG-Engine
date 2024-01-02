defaultTypeSpeed = game_get_speed(gamespeed_fps) / 30;
defaultNewlineStr = "";
defaultTextTransform = undefined;
defaultTextRender = undefined;
textTransformStruct = {char: "A", x: 0, y: 0, xscale: 1, yscale: 1, angle: 0};
defaultFont = draw_get_font();
textWrap = infinity;
lineSep = -1;

defaultTypeSound = undefined;
playTypeSound = false;

text = "";
progress = 0;

frame = 0;

set_text = function(str = "") {
	newlineStr = defaultNewlineStr;
	text = newlineStr + str;
	
	commandArray = [];
	paramArray = [];
	
	for (var i=1; i<=string_length(text); i++) {
		var char = string_char_at(text, i);
		
		if (char = "\n") {
			text = string_insert(newlineStr, text, i + 1);
			i += string_length(newlineStr);
			continue;
		}
		
		if (char = "\a") { //can't have any of these in there
			text = string_delete(text, i, 1);
			i --;
			continue;
		}
		
		if (char != "{") continue;
		
		if (string_char_at(text, i + 1) = "{") {
			text = string_delete(text, i, 1);
			continue;
		}
		
		//get command and parameters
		var endPos = string_pos_ext("}", text, i + 1);
		if (endPos = 0) break; //malformed command
		var params = string_copy(text, i + 1, endPos - i - 1);
		params = string_split(params, " ", true);
		if (array_length(params) <= 0) continue; //malformed command
		var commandName = params[0];
		var command = global.__text_data.command[$ commandName];
		array_delete(params, 0, 1);
		
		if (!is_struct(command)) { //command does not exist
			i = endPos;
			continue;
		}
		
		var init = command[$ "init"];
		if is_method(init) init(id, params);
		
		var newStr = "";
		
		if (!command.removable) { //command has types that run post-init
			var index = array_length(commandArray);
			commandArray[index] = command;
			paramArray[index] = params;
			newStr += "\a" + string_format(index, 2, 0);
		}
		
		var variable = command[$ "variable"];
		if (variable != undefined) {
			if is_method(variable) {
				newStr += string(variable(id, params));
			} else {
				newStr += string(variable);
			}
		}
		
		text = string_delete(text, i, endPos - i + 1);
		text = string_insert(newStr, text, i);
		i += string_length(newStr) - 1;
	}
	
	typeTimer = 1;
	typeSpeed = defaultTypeSpeed;
	typeSound = defaultTypeSound;
	progress = 0;
	progressMax = string_length(text);
	
	newlinePos = [infinity];
	lineWidth = [0];
	lineCount = 0;
	
	prevWrap = undefined;
	prevFont = undefined;
}

set_font = function(font) {
	defaultFont = font;
}

set_wrap = function(width = -1) {
	textWrap = (width >= 0) ? width : infinity;
}

set_line_sep = function(sep = -1) {
	lineSep = sep;
}

set_newline_str = function(str = "") {
	defaultNewlineStr = str;
}

set_effect = function(effect_name) {
	var command = global.__text_data.command[$ effect_name];
	if (command = undefined) {
		defaultTextTransform = undefined;
		defaultTextRender = undefined;
		return;
	}
	defaultTextTransform = command[$ "transform"];
	defaultTextRender = command[$ "render"];
}

set_sound = function(sound) {
	if (!is_handle(sound) && !is_array(sound)) sound = undefined;
	defaultTypeSound = sound;
	typeSound = sound;
}

set_speed = function(spd) {
	defaultTypeSpeed = game_get_speed(gamespeed_fps) / spd;
	typeSpeed = defaultTypeSpeed;
}

skip = function() {
	progress = progressMax;
}

is_finished = function() {
	return (progress >= progressMax);
}

draw = function(_x, _y, xscale = 1, yscale = 1, angle = 0) {
	if (prevFont != defaultFont || prevWrap != textWrap) {
		prevFont = defaultFont;
		prevWrap = textWrap;
		refresh(textWrap); //update word wrap
	}
	
	#region set values
	var oldColor = draw_get_color();
	var oldFont = draw_get_font();
	var oldHalign = draw_get_halign();
	var oldValign = draw_get_valign();
	
	defaultColor = oldColor;
	draw_set_font(defaultFont);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	switch oldHalign {
		default: halign = 0; break;
		case fa_center: halign = -0.5; break;
		case fa_right: halign = -1; break;
	}
	
	textTransform = defaultTextTransform;
	textRender = defaultTextRender;
	var newlineX = string_width(newlineStr);
	lineHeight = (lineSep >= 0) ? lineSep : string_height("M");
	drawX = _x;
	drawY = _y;
	drawXScale = xscale;
	drawYScale = yscale;
	drawAngle = angle;
	xx = halign * lineWidth[0];
	yy = 0;
	var lineIndex = 0;
	var wrapPos = newlinePos[0];
	#endregion
	
	for (var i=1; i<=progress; i++) {
		var char = string_char_at(text, i);
		
		if (i >= wrapPos) { //go to new line
			lineIndex ++;
			wrapPos = newlinePos[lineIndex];
			xx = halign * lineWidth[lineIndex];
			yy += lineHeight;
			
			if (i > 1) {
				if (string_char_at(text, i - 1) = "\n") {
					newlineX = string_width(newlineStr);
				} else {
					xx += newlineX;
				}
			}
		}
		
		if (char = "\a") {
			var index = real(string_copy(text, i + 1, 2));
			var command = commandArray[index];
			var func = command[$ "draw"];
			if is_method(func) func(id, paramArray[index]);
			textTransform = command[$ "transform"] ?? textTransform;
			if (textTransform = "reset") textTransform = defaultTextTransform;
			textRender = command[$ "render"] ?? textRender;
			if (textRender = "reset") textRender = defaultTextRender;
			i += 2;
		} else {
			#region transform text
			var trans = textTransformStruct;
			trans.char = char;
			trans.x = xx;
			trans.y = yy;
			trans.xscale = 1;
			trans.yscale = 1;
			trans.angle = 0;
			
			if (textTransform != undefined) {
				if is_method(textTransform) {
					textTransform(id, trans);
				} else switch textTransform {
				case "shake":
					trans.x += irandom_range(-1, 1);
					trans.y += irandom_range(-1, 1);
					break;
				case "wave":
					trans.y += sin(trans.x * 0.1 - current_time * 0.005) * 2;
					break;
				case "scared":
					if (irandom(200) = 0) {
						trans.y += irandom(1) * 2 - 1;
					}
					break;
				}
			}
			
			if (drawAngle != 0) {
				var tempX = trans.x * drawXScale;
				var tempY = trans.y * drawYScale;
				var sinA = dsin(drawAngle);
				var cosA = dcos(drawAngle);
				trans.x = drawX + cosA * tempX + sinA * tempY;
				trans.y = drawY + cosA * tempY - sinA * tempX;
				trans.angle += drawAngle;
			} else {
				trans.x = drawX + trans.x * drawXScale;
				trans.y = drawY + trans.y * drawYScale;
			}
			trans.xscale *= drawXScale;
			trans.yscale *= drawYScale;
			#endregion
			
			if is_method(textRender) {
				textRender(id, trans);
			} else {
				draw_text_transformed(trans.x, trans.y, trans.char, trans.xscale, trans.yscale, trans.angle);
			}
			xx += string_width(char);
		}
	}
	
	draw_set_color(oldColor);
	draw_set_font(oldFont);
	draw_set_halign(oldHalign);
	draw_set_valign(oldValign);
}

refresh = function(wrap) {
	var oldFont = draw_get_font();
	draw_set_font(defaultFont);
	var maxWidth = wrap;
	var newlineX = string_width(newlineStr);
	var xx = 0;
	var width = 0;
	wordWidth = 0;
	var wrapPos = 0;
	var lineIndex = 0;
	var str = text + "\n";
	
	for (var i=1; i<=progressMax+1; i++) {
		var char = string_char_at(str, i);
		
		if (char = " " || char = "\n") {
			if (wordWidth > 0) {
				if (xx + wordWidth > maxWidth) {
					lineWidth[lineIndex] = width;
					newlinePos[lineIndex] = wrapPos;
					lineIndex ++;
					xx = newlineX;
				}
				
				xx += wordWidth;
				width = xx;
				wordWidth = 0;
			}
			
			wrapPos = i + 1;
			
			if (char = "\n") {
				lineWidth[lineIndex] = width;
				newlinePos[lineIndex] = wrapPos;
				lineIndex ++;
				newlineX = string_width(newlineStr);
				xx = 0;
				width = 0;
				wordWidth = 0;
			} else {
				xx += string_width(char);
			}
		} else if (char = "\a") {
			var index = real(string_copy(text, i + 1, 2));
			var command = commandArray[index];
			var func = command[$ "refresh"];
			if is_method(func) func(id, paramArray[index]);
			i += 2;
		} else {
			wordWidth += string_width(char);
		}
	}
	
	lineCount = lineIndex;
	draw_set_font(oldFont);
}

#region in text commands API
play_type_sound = function() {
	playTypeSound = true;
}

wait = function(time = 1) {
	typeTimer += typeSpeed * time;
}

wait_seconds = function(seconds) {
	typeTimer += game_get_speed(gamespeed_fps) * seconds;
}
#endregion