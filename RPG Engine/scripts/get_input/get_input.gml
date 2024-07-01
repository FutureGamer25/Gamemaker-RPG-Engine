function get_input(verb) {
	switch (verb) {
	case "horizontal":
		return keyboard_check(vk_right) - keyboard_check(vk_left);
	case "vertical":
		return keyboard_check(vk_down) - keyboard_check(vk_up);
	case "confirm":
		return keyboard_check(vk_enter) || keyboard_check(ord("Z"));
	case "cancel":
		return keyboard_check(vk_shift) || keyboard_check(ord("X"));
	default:
		if (string_length(verb) = 1) {
			var num = ord(string_upper(verb));
			return keyboard_check(num);
		}
	}
}

function get_input_pressed(verb) {
	switch (verb) {
	case "up":
		return keyboard_check_pressed(vk_up);
	case "down":
		return keyboard_check_pressed(vk_down);
	case "left":
		return keyboard_check_pressed(vk_left);
	case "right":
		return keyboard_check_pressed(vk_right);
	case "confirm":
		return keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("Z"));
	case "cancel":
		return keyboard_check_pressed(vk_shift) || keyboard_check_pressed(ord("X"));
	default:
		if (string_length(verb) = 1) {
			var num = ord(string_upper(verb));
			return keyboard_check_pressed(num);
		}
	}
}