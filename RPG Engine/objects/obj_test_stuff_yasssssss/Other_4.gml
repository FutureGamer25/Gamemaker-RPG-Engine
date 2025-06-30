#region cutscene testing

//define cutscene
cutscene = cutscene_begin();

scene_func(function() {
	asd = instance_create_depth(0, 0, 0, obj_ice_cream_man);
});

scene_label("label");

scene_branch_start();
	scene_lerp(360, 0, 100, "", function(angle) {
		asd.image_angle = angle;
	});
scene_branch_end();
scene_lerp(1, 2, 40, "", function(scale) {
	asd.image_xscale = scale;
});
scene_lerp(2, 1, 100, "", function(scale) {
	asd.image_xscale = scale;
});

scene_obj_move("v:asd", marker_get("A").x, marker_get("A").y, 30);
scene_obj_move_speed("v:asd", 60, 0, 4);
scene_wait(10);

scene_obj_move("v:asd", 30, 30, 60);
scene_lerp(0, 360, 200, "cubic", function(angle) {
	asd.image_angle = angle;
});
scene_obj_move("v:asd", 60, 60, 60);
scene_wait(60);
scene_obj_move_speed("v:asd", 0, 60, 2);
scene_wait(10);
scene_obj_move_speed("v:asd", 0, 0, 2);
scene_wait(10);

scene_goto("label");

cutscene_end();

#endregion



#region text effects testing
text_add_transform_effect("circle_of_friendship", function(inst, trans) {
	var startSize = 50;
	var size = startSize - trans.y;
	var a = trans.x / size + current_time / 500;
	trans.x = startSize - cos(a) * size;
	trans.y = startSize - sin(a) * size;
	trans.angle += 90 - a * 180 / pi;
});

text_add_render_effect("circle_of_friendship", function(inst, trans) {
	var _x = trans.x + random_range(-1, 1);
	var _y = trans.y + random_range(-1, 1);
	var angle = trans.angle + random_range(-20, 20);
	var xscale = trans.xscale;
	var yscale = trans.yscale;
	var char = trans.char;
	
	var col = draw_get_color();
	draw_set_color(c_black);
	draw_text_transformed(_x+1, _y, char, xscale, yscale, angle);
	draw_text_transformed(_x-1, _y, char, xscale, yscale, angle);
	draw_text_transformed(_x, _y+1, char, xscale, yscale, angle);
	draw_text_transformed(_x, _y-1, char, xscale, yscale, angle);
	draw_set_color(make_color_hsv(irandom(255), 200, 255));
	draw_text_transformed(_x, _y, char, xscale, yscale, angle);
	draw_set_color(col);
});

textObj = text_create(lang_get("circle of friendship"));
#endregion