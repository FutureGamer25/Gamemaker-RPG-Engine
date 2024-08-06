//Feather ignore GM2017
//Feather ignore GM1042
///@param {Any} value_or_format
///@param {Any} [...]
function print(__val) {
	static __arr = [];
	
	if (argument_count = 1) {
		show_debug_message(__val);
		return;
	}
	
	var __count = argument_count - 1;
	if (__count != array_length(__arr)) array_resize(__arr, __count);
	for (var __i=0; __i<__count; __i++) {
		__arr[__i] = argument[__i + 1];
	}
	
	show_debug_message_ext(string(__val), __arr);
}