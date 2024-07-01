if fadeIn {
	value += fadeSpeed;
	if (value >= 1) {
		value = 1;
		room_goto(newRoom);
		fadeIn = false;
	}
} else {
	value -= fadeSpeed;
	if (value <= 0) {
		value = 0;
		instance_destroy();
	}
}