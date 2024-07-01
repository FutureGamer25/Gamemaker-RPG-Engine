function draw_sprite_bounds(sprite, subimg, left, top, right, bottom, x, y) {
    draw_sprite_part(sprite, subimg, left - x, top - y, right - left, bottom - top, left, top);
}