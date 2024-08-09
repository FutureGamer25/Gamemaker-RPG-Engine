function move_and_collide_ext(dx, dy, obj, max_slide_angle = 60, slide_mode = slide_mode_normal, rounded = false, linear_prec = 2, angle_prec = 3) {
	
	static _normal_multi = function(_cos, _x, _y, _param) { return _cos; };
	static _circle_multi = function(_cos, _x, _y, _param) { return _cos; };
	static _square_multi = function(_cos, _x, _y, _param) {
		return _param / max(abs(_x), abs(_y));
	};
	
	if (!place_meeting(x + dx, y + dy, obj)) {
		x += dx;
		y += dy;
		return;
	}
	
	var xNew, yNew, _x, _y, lower, upper, middle, minDist;
	
	#region collide
	var xRound = false;
	var yRound = false;
	xNew = x;
	yNew = y;
	
	if (rounded) {
		if (dx != 0) {
			xRound = true;
			xNew = round(xNew);
		}
		if (dy != 0) {
			yRound = true;
			yNew = round(yNew);
		}
	}
	
	minDist = 1 / (1 + (1 << linear_prec));
	lower = minDist;
	upper = 1;
	
	_x = x + dx * lower;
	_y = y + dy * lower;
	if (xRound) _x = round(_x);
	if (yRound) _y = round(_y);
	
	if (!place_meeting(x + dx * minDist, y + dy * minDist, obj)) {
		xNew = _x;
		yNew = _y;
		repeat(linear_prec) {
			middle = (lower + upper) * 0.5;
			_x = x + dx * middle;
			_y = y + dy * middle;
			if (xRound) _x = round(_x);
			if (yRound) _y = round(_y);
			
			if (place_meeting(_x, _y, obj)) {
				upper = middle;
			} else {
				lower = middle;
				xNew = _x;
				yNew = _y;
			}
		}
	}
	
	x = xNew;
	y = yNew;
	#endregion
	
	if (slide_mode = slide_mode_none) return;
	
	#region slide
	dx *= 1 - lower;
	dy *= 1 - lower;
	
	//var angle = arctan2(dy, dx);
	//var dist = point_distance(0, 0, dx, dy);
	
	var _get_multi = _circle_multi;
	var _param = undefined;
	switch (slide_mode) {
		case slide_mode_normal:
		_get_multi = _normal_multi;
		break;
		case slide_mode_square:
		_param = max(abs(dx), abs(dy));
		_get_multi = _square_multi;
		break;
	}
	
	lower = 0;
	upper = max_slide_angle * pi / 180;
	
	var _cos = cos(upper);
	var _sin = sin(upper);
	_x = _cos * dx - _sin * dy;
	_y = _cos * dy + _sin * dx;
	var mul = _get_multi(_cos, _x, _y, _param);
	_x = x + _x * mul;
	_y = y + _y * mul;
	if (rounded) {
		_x = round(_x);
		_y = round(_y);
	}
	if place_meeting(_x, _y, obj) {
		upper *= -1;
		_sin *= -1;
		_x = _cos * dx - _sin * dy;
		_y = _cos * dy + _sin * dx;
		mul = _get_multi(_cos, _x, _y, _param);
		_x = x + _x * mul;
		_y = y + _y * mul;
		if (rounded) {
			_x = round(_x);
			_y = round(_y);
		}
		if place_meeting(_x, _y, obj) return;
	};
	
	xNew = _x;
	yNew = _y;
	
	repeat(angle_prec) {
		middle = (lower + upper) * 0.5;
		_cos = cos(middle);
		_sin = sin(middle);
		_x = _cos * dx - _sin * dy;
		_y = _cos * dy + _sin * dx;
		mul = _get_multi(_cos, _x, _y, _param);
		_x = x + _x * mul;
		_y = y + _y * mul;
		if (rounded) {
			_x = round(_x);
			_y = round(_y);
		}
		if (place_meeting(_x, _y, obj)) {
			lower = middle;
		} else {
			upper = middle;
			xNew = _x;
			yNew = _y;
		}
	}
	
	x = xNew;
	y = yNew;
	#endregion
}

#macro slide_mode_none (0)
#macro slide_mode_normal (1)
#macro slide_mode_circle (2)
#macro slide_mode_square (3)