frame ++;

if (progress >= progressMax) exit;

typeTimer --;

while (progress < progressMax && typeTimer <= 0) {
	progress ++;
	var char = string_char_at(text, progress);
	
	if (char = "\a") {
		var index = real(string_copy(text, progress + 1, 2));
		var command = commandArray[index];
		var func = command[$ "type"];
		if is_method(func) func(id, paramArray[index]);
		progress += 2;
	} else {
		var delay = global.__text_data.delay[$ char] ?? 1;
		typeTimer += typeSpeed * delay;
	}
	
	if (typeSound != undefined) {
		if (char != "\a" && string_pos(char, global.__text_data.silent) = 0) {
			playTypeSound = true;
		}
	}
}

if playTypeSound {
	playTypeSound = false;
	if (typeSound != undefined) {
		var snd = typeSound;
		if is_method(typeSoundFunc) {
			typeSoundFunc(snd);
		} else {
			if is_array(typeSound) {
				//feather disable once all
				snd = typeSound[ irandom(array_length(typeSound) - 1) ];
				if (!is_handle(snd)) snd = -1;
			}
			if audio_exists(snd) audio_play_sound(snd, 0, false, global.__text_data.gain);
		}
	}
}