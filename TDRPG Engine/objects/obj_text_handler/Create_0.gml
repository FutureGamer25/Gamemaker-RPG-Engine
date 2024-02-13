text = "";
progress = 0;

//typing
defaultTypeSpeed = game_get_speed(gamespeed_fps) / 30;
defaultTypeSound = undefined;
playTypeSound = false;
frame = 0;

//text effects
defaultTextTransform = undefined;
defaultTextRender = undefined;
textTransformStruct = {char: "", x: 0, y: 0, xscale: 1, yscale: 1, angle: 0};
defaultTransformParams = undefined;
defaultRenderParams = undefined;

defaultNewlineStr = "";
defaultFont = draw_get_font();

//refresh data
prevFont = undefined;
prevWrap = undefined;
textWrap = infinity;
lineSep = -1;
lineWidth = [0];
lineHeight = [0];
newlinePos = [infinity];
lineCount = 0;
textWidth = 0;
textHeight = 0;

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
	frame = 0;
	
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

set_effect = function(effect_name, parameters = []) {
	var command = global.__text_data.command[$ effect_name];
	if (command = undefined) {
		defaultTextTransform = undefined;
		defaultTextRender = undefined;
		defaultTransformParams = undefined;
		defaultRenderParams = undefined;
		return;
	}
	defaultTextTransform = command[$ "transform"];
	defaultTextRender = command[$ "render"];
	defaultTransformParams = parameters;
	defaultRenderParams = parameters;
}

set_sound = function(sound) {
	if (!audio_exists(sound) && !is_array(sound)) sound = undefined;
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

get_width = function() {
	refresh(); //update word wrap
	return textWidth;
}

get_height = function() {
	refresh(); //update word wrap
	if (lineSep < 0) return textHeight;
	var maxLine = lineCount - 1;
	return lineSep * maxLine + 0.5 * (lineHeight[0] + lineHeight[maxLine]);
}

get_line_count = function() {
	return lineCount;
}

draw = function(_x, _y, xscale = 1, yscale = 1, angle = 0) {
	refresh(); //update word wrap
	
	#region set values
	var oldColor = draw_get_color();
	var oldFont = draw_get_font();
	var oldHalign = draw_get_halign();
	var oldValign = draw_get_valign();
	
	defaultColor = oldColor;
	draw_set_font(defaultFont);
	draw_set_halign(fa_left);
	draw_set_valign(fa_middle);
	switch oldHalign {
		default: halign = 0; break;
		case fa_center: halign = -0.5; break;
		case fa_right: halign = -1; break;
	}
	switch oldValign {
		default: valign = 0; break;
		case fa_middle: valign = -0.5; break;
		case fa_bottom: valign = -1; break;
	}
	
	textTransform = defaultTextTransform;
	textRender = defaultTextRender;
	textTransformParams = defaultTransformParams;
	textRenderParams = defaultRenderParams;
	drawX = _x;
	drawY = _y;
	drawXScale = xscale;
	drawYScale = yscale;
	drawAngle = angle;
	drawSin = dsin(drawAngle);
	drawCos = dcos(drawAngle);
	xx = halign * lineWidth[0];
	yy = valign * get_height();
	textXScale = 1;
	textYScale = 1;
	textAngle = 0;
	textLineHeight = (lineSep >= 0)? lineSep: lineHeight[0];
	textYOffset = lineHeight[0] * 0.5;
	
	var newlineX = string_width(newlineStr);
	var lineIndex = 0;
	var wrapPos = newlinePos[0];
	#endregion
	
	for (var i=1; i<=progress; i++) {
		var char = string_char_at(text, i);
		
		if (i >= wrapPos) { //go to new line
			lineIndex ++;
			wrapPos = newlinePos[lineIndex];
			xx = halign * lineWidth[lineIndex];
			yy += textLineHeight;
			if (lineSep < 0) {
				textLineHeight = lineHeight[lineIndex];
				textYOffset = textLineHeight * 0.5;
			}
			
			if (i > 1) {
				if (string_char_at(text, i - 1) = "\n") {
					newlineX = string_width(newlineStr);
				} else {
					xx += newlineX;
				}
			}
		}
		
		if (char = "\a") {
			#region commands
			var index = real(string_copy(text, i + 1, 2));
			var command = commandArray[index];
			var params = paramArray[index];
			
			var func = command[$ "draw"];
			if is_method(func) func(id, params);
			
			var effect = command[$ "transform"];
			if (effect = "reset") {
				textTransform = defaultTextTransform;
				textTransformParams = defaultTransformParams;
			} else if is_method(effect) {
				textTransform = effect;
				textTransformParams = params;
			}
			
			effect = command[$ "render"];
			if (effect = "reset") {
				textRender = defaultTextRender;
				textRenderParams = defaultRenderParams;
			} else if is_method(effect) {
				textRender = effect;
				textRenderParams = params;
			}
			
			i += 2;
			#endregion
		} else {
			var trans = update_transform_struct(char, 0, textYOffset);
			
			#region render text
			if is_method(textRender) {
				textRender(id, trans, textRenderParams);
			} else {
				draw_text_transformed(trans.x, trans.y, trans.char, trans.xscale, trans.yscale, trans.angle);
			}
			#endregion
			
			xx += string_width(char) * textXScale;
		}
	}
	
	draw_set_color(oldColor);
	draw_set_font(oldFont);
	draw_set_halign(oldHalign);
	draw_set_valign(oldValign);
}

#region internal
refresh = function() {
	if (prevFont = defaultFont && prevWrap = textWrap) return;
	prevFont = defaultFont;
	prevWrap = textWrap;
	
	var oldFont = draw_get_font();
	draw_set_font(defaultFont);
	var newlineX = string_width(newlineStr);
	var xx = 0;
	textXScale = 1;
	textYScale = 1;
	textAngle = 0;
	var width = 0;
	var height = 0;
	wordWidth = 0;
	wordHeight = 0;
	var wrapPos = 0;
	var str = text + "\n";
	lineCount = 0;
	textWidth = 0;
	textHeight = 0;
	
	for (var i=1; i<=progressMax+1; i++) {
		var char = string_char_at(str, i);
		
		if (char = " " || char = "\n") {
			if (wordWidth > 0) {
				if (xx + wordWidth > textWrap) { //wrap
					lineWidth[lineCount] = width;
					lineHeight[lineCount] = height;
					newlinePos[lineCount] = wrapPos;
					lineCount ++;
					
					textWidth = max(textWidth, width);
					textHeight += height;
					
					//reset line
					xx = newlineX;
					width = 0;
					height = 0;
				}
				
				//add word to line
				xx += wordWidth;
				width = xx;
				height = max(height, wordHeight);
				wordWidth = 0;
				wordHeight = 0;
			}
			
			wrapPos = i + 1;
			
			if (char = "\n") { //newline
				if (height = 0) height = string_height(char) * textYScale;
				
				lineWidth[lineCount] = width;
				lineHeight[lineCount] = height;
				newlinePos[lineCount] = wrapPos;
				lineCount ++;
				
				textWidth = max(textWidth, width);
				textHeight += height;
				
				newlineX = string_width(newlineStr);
				//reset line
				xx = 0;
				width = 0;
				height = 0;
			} else {
				xx += string_width(char) * textXScale;
				//height = max(height, string_height(char) * textYScale);
			}
		} else if (char = "\a") {
			var index = real(string_copy(text, i + 1, 2));
			var command = commandArray[index];
			var func = command[$ "refresh"];
			if is_method(func) func(id, paramArray[index]);
			i += 2;
		} else {
			wordWidth += string_width(char) * textXScale;
			wordHeight = max(wordHeight, string_height(char) * textYScale);
		}
	}
	
	draw_set_font(oldFont);
}

update_transform_struct = function(char, xoffset, yoffset) {
	var trans = textTransformStruct;
	trans.char = char;
	trans.x = xx + xoffset;
	trans.y = yy + yoffset;
	trans.xscale = textXScale;
	trans.yscale = textYScale;
	trans.angle = textAngle;
	
	if is_method(textTransform) {
		textTransform(id, trans, textTransformParams);
	}
	
	if (drawAngle != 0) {
		var tempX = trans.x * drawXScale;
		var tempY = trans.y * drawYScale;
		trans.x = drawX + drawCos * tempX + drawSin * tempY;
		trans.y = drawY + drawCos * tempY - drawSin * tempX;
		trans.angle += drawAngle;
	} else {
		trans.x = drawX + trans.x * drawXScale;
		trans.y = drawY + trans.y * drawYScale;
	}
	trans.xscale *= drawXScale;
	trans.yscale *= drawYScale;
	return trans;
}
#endregion

#region in text commands API
#region misc
get_type_frame = function() {
	return frame;
}
#endregion

#region refresh
refresh_add_width = function(width) {
	wordWidth += width;
}

refresh_add_height = function(height) {
	wordHeight = max(wordHeight, height);
}

refresh_set_xscale = function(xscale) {
	textXScale = xscale;
}

refresh_set_yscale = function(yscale) {
	textYScale = yscale;
}
#endregion

#region draw
draw_add_width = function(width) {
	xx += width;
}

draw_add_height = function(height) {
	//nothing for now
}

draw_set_xscale = refresh_set_xscale;
draw_set_yscale = refresh_set_yscale;

draw_get_transform = function(xoffset = 0, yoffset = 0) {
	return update_transform_struct("", xoffset, yoffset + textYOffset);
}
#endregion

#region type
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
#endregion