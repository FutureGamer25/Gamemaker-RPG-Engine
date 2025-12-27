#region cutscene testing

//define cutscene
cutscene = cutscene_begin();

cs_func(function() {
	asd = instance_create_depth(0, 0, 0, obj_ice_cream_man);
});

cs_label("label");


cs_branch_begin();
	cs_anime_tween(360, 0, 100, anime_curve.linear, function(angle) {
		asd.image_angle = angle;
	});
cs_branch_end();
cs_anime_tween(1, 2, 40, "linear", function(scale) {
	asd.image_xscale = scale;
});
cs_anime_tween(2, 1, 100, "linear", function(scale) {
	asd.image_xscale = scale;
});

cs_time_units(cutscene_units_seconds);
cs_func(function() {
	cs_obj_move(asd, marker_get("A").x, marker_get("A").y, 1);
	cs_obj_move_speed(asd, 60, 0, 120);
});
cs_wait(0.3);

cs_func(function() { cs_obj_move(asd, 30, 30, 2); });
cs_anime_tween(0, 360, 7, "cubic_in_out", function(angle) {
	asd.image_angle = angle;
});
cs_func(function() {
	cs_obj_move(asd, 60, 60, 2);
	cs_wait(2);
	cs_obj_move_speed(asd, 0, 60, 60);
	cs_time_units(cutscene_units_frames);
	cs_wait(10);
	cs_obj_move_speed(asd, 0, 0, 2);
});
cs_wait(10);

cs_goto_label("label");

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