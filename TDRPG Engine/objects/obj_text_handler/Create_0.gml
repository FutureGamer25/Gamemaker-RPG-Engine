defaultSpeed = game_get_speed(gamespeed_fps) / 30;
defaultStyle = "";
defaultNewlineStr = "";

defaultSound = -1;
playSound = false;

text = "";
progress = 0;

frame = 0;

set_text = function(str = "") {
	newlineStr = defaultNewlineStr;
	text = newlineStr + str;
	
	funcType = [];
	funcDraw = [];
	funcParams = [];
	
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
		
		var endPos = string_pos_ext("}", text, i + 1);
		if (endPos = 0) break;
		var params = string_copy(text, i + 1, endPos - i - 1);
		params = string_split(params, " ", true);
		if (array_length(params) <= 0) continue;
		var command = params[0];
		array_delete(params, 0, 1);
		
		var func = global.text_data.func[$ command];
		var newStr = "";
		
		switch typeof(func) {
		case "undefined":
			i = endPos;
			continue;
		case "array": //function
			var index = array_length(funcParams);
			var init = func[0]; //init
			funcType[index] = func[1]; //type
			funcDraw[index] = func[2]; //draw
			funcRefresh[index] = func[3]; //refresh (word wrap)
			funcParams[index] = params;
			
			if is_method(init) init(id, params);
			newStr = "\a" + string_format(index, 2, 0);
			break;
		case "method": //func variable
			newStr = func(id, params);
			break;
		default: //variable
			newStr = func;
			break;
		}
		
		text = string_delete(text, i, endPos - i + 1);
		newStr = string(newStr);
		text = string_insert(newStr, text, i);
		i += string_length(newStr) - 1;
	}
	
	typeTimer = 1;
	typeSpeed = defaultSpeed;
	typeSound = defaultSound;
	progress = 0;
	progressMax = string_length(text);
	
	newlinePos = [infinity];
	lineWidth = [0];
	lineCount = 0;
	
	prevWidth = undefined;
	prevFont = undefined;
}

set_newline_str = function(str = "") {
	defaultNewlineStr = str;
}

set_style = function(style) {
	defaultStyle = style;
}

set_sound = function(sound) {
	if (!is_real(sound)) sound = -1;
	defaultSound = sound;
	typeSound = sound;
}

set_speed = function(spd) {
	defaultSpeed = game_get_speed(gamespeed_fps) / spd;
	typeSpeed = defaultSpeed;
}

skip = function() {
	progress = progressMax;
}

is_finished = function() {
	return (progress >= progressMax);
}

draw = function(_x, _y, sep = -1, w = -1, scale = 1) {
	var font = draw_get_font();
	w = (w >= 0) ? w : infinity;
	
	if (prevFont != font || prevWidth != w) {
		prevFont = font;
		prevWidth = w;
		refresh(w); //update word wrap
	}
	
	#region set values
	defaultColor = draw_get_color();
	defaultFont = font;
	defaultHalign = draw_get_halign();
	switch defaultHalign {
		default: halign = 0; break;
		case fa_center: halign = -0.5; break;
		case fa_right: halign = -1; break;
	}
	draw_set_halign(fa_left);
	defaultValign = draw_get_valign();
	draw_set_valign(fa_top);
	
	textStyle = defaultStyle;
	var newlineX = string_width(newlineStr);
	lineHeight = (sep >= 0) ? sep : string_height("M");
	drawScale = scale;
	drawX = _x;
	drawY = _y;
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
			var func = funcDraw[index];
			if (!is_undefined(func)) func(id, funcParams[index]);
			i += 2;
		} else {
			#region transform text
			var charX = xx;
			var charY = yy;
			var charSclX = 1;
			var charSclY = 1;
			var charAngle = 0;
			
			switch textStyle {
			case "shake":
				charX += irandom_range(-1, 1);
				charY += irandom_range(-1, 1);
				break;
			case "wave":
				charY += sin(xx * 0.1 - current_time * 0.005) * 2;
				break;
			case "scared":
				if (irandom(200) = 0) {
					charY += irandom(1) * 2 - 1;
				}
				break;
			}
			
			charX = drawX + charX * drawScale;
			charY = drawY + charY * drawScale;
			charSclX *= drawScale;
			charSclY *= drawScale;
			#endregion
			
			draw_text_transformed(charX, charY, char, charSclX, charSclY, charAngle);
			xx += string_width(char);
		}
	}
	
	draw_set_color(defaultColor);
	draw_set_font(defaultFont);
	draw_set_halign(defaultHalign);
	draw_set_valign(defaultValign);
}

refresh = function(w) {
	defaultFont = draw_get_font();
	var drawWidth = w;
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
				if (xx + wordWidth > drawWidth) {
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
			var func = funcRefresh[index];
			if (!is_undefined(func)) func(id, funcParams[index]);
			i += 2;
		} else {
			wordWidth += string_width(char);
		}
	}
	
	lineCount = lineIndex;
	draw_set_font(defaultFont);
}