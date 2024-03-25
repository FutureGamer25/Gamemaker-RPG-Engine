if get_pause() {
	running = false;
	char_sprite_state_delay(charSprite, "stand");
	char_sprite_update(charSprite);
	follower_update(false, undefined)
} else {


var horizontal = get_input("horizontal");
var vertical = get_input("vertical");
var run = get_input("cancel");
var interact = get_input_pressed("confirm");

#region move
running = run;
var moveSpeed = running ? runSpeed : walkSpeed;
image_speed = 1 + running;

var moveX = horizontal * moveSpeed
var moveY = vertical * moveSpeed;

if (moveX != 0) {
	x += moveX;
	if place_meeting(x, y, obj_wall) {
		x = floor(x);
		while (place_meeting(x, y, obj_wall)) {
			x -= sign(moveX);
		}
		moveX = 0;
	}
}

if (moveY != 0) {
	y += moveY;
	if place_meeting(x, y, obj_wall) {
		y = floor(y);
		while (place_meeting(x, y, obj_wall)) {
			y -= sign(moveY);
		}
		moveY = 0;
	}
}

var moving = (moveX != 0 || moveY != 0);
#endregion

#region sprites
if moving {
	char_sprite_state(charSprite, "walk");
} else {
	char_sprite_state_delay(charSprite, "stand");
}

char_sprite_dir(charSprite, horizontal, vertical);
#endregion

#region interact
if interact {
	var faceX = char_sprite_get_x(charSprite);
	var faceY = char_sprite_get_y(charSprite);
	var xx = x + faceX * interactDist;
	var yy = y + faceY * interactDist;
	ds_list_clear(interactList);
	instance_place_list(xx, yy, all, interactList, false);
	
	for (var i=0; i<ds_list_size(interactList); i++) {
		var inst = interactList[|i];
		if asset_has_tags(inst.object_index, "interact", asset_object) {
			with inst event_user(0);
			break;
		}
	}
}
#endregion

char_sprite_update(charSprite);
follower_update(moving, {
	x: x,
	y: y,
	dirX: char_sprite_get_x(charSprite),
	dirY: char_sprite_get_y(charSprite),
	state: char_sprite_get_state(charSprite),
	run: running,
});


} //end pause