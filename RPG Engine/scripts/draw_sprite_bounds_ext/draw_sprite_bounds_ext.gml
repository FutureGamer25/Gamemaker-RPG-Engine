function draw_sprite_bounds_ext(sprite, subimg, left, top, right, bottom, x, y, xscale, yscale, col, alpha) {
	var xpos = xscale >= 0 ? left : right;
	var ypos = yscale >= 0 ? top : bottom;
    draw_sprite_part_ext(
		sprite, subimg, (xpos - x) / xscale, (ypos - y) / yscale,
		(right - left) / abs(xscale), (bottom - top) / abs(yscale),
		xpos, ypos, xscale, yscale, col, alpha
	);
}