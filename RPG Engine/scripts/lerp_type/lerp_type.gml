///@desc	Interpolate two values with an easing curve.
///@param {Real} val1				The first value
///@param {Real} val2				The second value
///@param {Real} amount				The amount to interpolate
///@param {String} ease_type		The easing curve
///@return {Real}
function lerp_type(val1, val2, amount, ease_type) {
	#region interpolate functions
	static quad = function(val) {
		return val * val;
	}
	static cubic = function(val) {
		return val * val * val;
	}
	static quart = function(val) {
		return val * val * val * val;
	}
	static quint = function(val) {
		return val * val * val * val * val;
	}
	static sine = function(val) {
		return sin(val * pi * 0.5);
	}
	static expo = function(val) {
		if (val <= 0) return 0;
		return exp(val * 7 - 7)
	}
	static circ = function(val) {
		return 1 - sqrt(max(1 - (val * val), 0));
	}
	static back = function(val) {
		static c1 = 1.70158;
		static c3 = c1 + 1;
		
		return (c3 * val - c1) * val * val;
	}
	static elastic = function(val) {
		static c4 = 2 * pi / 3;
		
		if (val <= 0) return 0;
		if (val >= 1) return 1;
		return power(2, -10 * val) * sin((val * 10 - 0.75) * c4) + 1;
	}
	static bounce = function(val) {
		static n1 = 7.5625;
		static d1 = 2.75;
		
		if (val < 1 / d1) {
		    return n1 * val * val;
		} else if (val < 2 / d1) {
			val -= 1.5 / d1;
		    return n1 * val * val + 0.75;
		} else if (val < 2.5 / d1) {
			val -= 2.25 / d1;
		    return n1 * val * val + 0.9375;
		} else {
			val -= 2.625 / d1;
		    return n1 * val * val + 0.984375;
		}
	}
	#endregion
	
	static type = {
		"linear" : [0, function(val) { return val; }],
		"smooth" : [2, quad],
		"nearest" : [0, function(val) { return (val >= 0.5); }],
		"hold" : [0, function(val) { return (val >= 1) }],
		
		"ease_in"     : [0, quad], //duplicate of quad
		"ease_out"    : [1, quad],
		"ease_in_out" : [2, quad],
		"ease_out_in" : [3, quad],
		"ease"        : [2, quad],
		
		"quad_in"     : [0, quad],
		"quad_out"    : [1, quad],
		"quad_in_out" : [2, quad],
		"quad_out_in" : [3, quad],
		"quad"        : [2, quad],
		
		"cubic_in"     : [0, cubic],
		"cubic_out"    : [1, cubic],
		"cubic_in_out" : [2, cubic],
		"cubic_out_in" : [3, cubic],
		"cubic"        : [2, cubic],
		
		"quart_in"     : [0, quart],
		"quart_out"    : [1, quart],
		"quart_in_out" : [2, quart],
		"quart_out_in" : [3, quart],
		"quart"        : [2, quart],
		
		"quint_in"     : [0, quint],
		"quint_out"    : [1, quint],
		"quint_in_out" : [2, quint],
		"quint_out_in" : [3, quint],
		"quint"        : [2, quint],
		
		"sine_in"     : [1, sine],
		"sine_out"    : [0, sine],
		"sine_in_out" : [3, sine],
		"sine_out_in" : [2, sine],
		"sine"        : [3, sine],
		
		"expo_in"     : [0, expo],
		"expo_out"    : [1, expo],
		"expo_in_out" : [2, expo],
		"expo_out_in" : [3, expo],
		"expo"        : [2, expo],
		
		"circ_in"     : [0, circ],
		"circ_out"    : [1, circ],
		"circ_in_out" : [2, circ],
		"circ_out_in" : [3, circ],
		"circ"        : [2, circ],
		
		"back_in"     : [0, back],
		"back_out"    : [1, back],
		"back_in_out" : [2, back],
		"back_out_in" : [3, back],
		"back"        : [1, back],
		
		"elastic_in"     : [1, elastic],
		"elastic_out"    : [0, elastic],
		"elastic_in_out" : [3, elastic],
		"elastic_out_in" : [2, elastic],
		"elastic"        : [0, elastic],
		
		"bounce_in"     : [1, bounce],
		"bounce_out"    : [0, bounce],
		"bounce_in_out" : [3, bounce],
		"bounce_out_in" : [2, bounce],
		"bounce"        : [0, bounce],
	}
	
	var interp = type[$ ease_type] ?? type.linear;
	
	switch interp[0] {
	case 0: //normal
		amount = interp[1](amount);
		break;
	case 1: //reverse
		amount = 1 - interp[1](1 - amount);
		break;
	case 2: //normal-reverse
		amount = 2 * amount - 1;
		var s1 = sign(amount);
		amount = 0.5 * (1 - interp[1](1 - s1 * amount)) * s1 + 0.5;
		break;
	case 3: //reverse-normal
		amount = 2 * amount - 1;
		var s2 = sign(amount);
		amount = 0.5 * interp[1](s2 * amount) * s2 + 0.5;
		break;
	}
	
	return val1 * (1 - amount) + val2 * amount;
}