cutscene = undefined;

anime_begin_ext(0, true, true, 1 / game_get_speed(gamespeed_fps), function(_val) { obj_player.x = _val; });
anime_add(50, 2, anime_curve.elastic_in_out);
anime_add(100, 0);
anime_add(150, 2, anime_curve.elastic_in);
anime_end();