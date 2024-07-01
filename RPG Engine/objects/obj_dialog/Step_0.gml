if (!checkInputs) exit;

var confirm = get_input_pressed("confirm");
var cancel = get_input_pressed("cancel");

if (state = "text") {
	if (textObj.is_finished()) {
		if confirm {
			if (!next_page()) {
				close();
			}
		}
	} else {
		if cancel {
			textObj.skip();
		}
	}
} else { //choice
	if confirm {
		state = "text";
		var key = optionKey[optionSelected];
		if is_undefined(key) {
			if (!next_page()) {
				close();
			}
		} else {
			set_text(lang_get_array(key));
		}
		exit;
	}
	
	var vertical = get_input_pressed("down") - get_input_pressed("up");
	optionSelected = modulo(optionSelected + vertical, array_length(optionKey));
}