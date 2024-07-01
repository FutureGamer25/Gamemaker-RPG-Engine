function follower_snap_to_player() {
	if (!instance_exists(obj_player)) return;
	with obj_follower {
		x = obj_player.x;
		y = obj_player.y;
		char_sprite_angle(charSprite, char_sprite_get_angle(obj_player.charSprite));
		char_sprite_state(charSprite, "stand");
	}
	follower_history_clear();
}

#region unfinished
function follower_history_rebuild(data_func) { //create snake at current follower positions
	//var pos1 = 0;
	//var x1 = obj_player.x;
	//var y1 = obj_player.y;
	//var x2 = x1;
	//var y2 = y1;
	//var move_x = 0;
	//var move_y = 0;
	//
	//for (var i=0; i<folCount; i++) {
	//	var fol = follower[i];
	//	var pos2 = (i + 1) * folSpacing;
	//	x2 = fol.x;
	//	y2 = fol.y;
	//	move_x = (x1 - x2) / folSpacing;
	//	move_y = (y1 - y2) / folSpacing;
	//	
	//	for (var j=pos1; j<pos2; j++) {
	//		var n = (j - pos1) / folSpacing;
	//		var _x = lerp(x1, x2, n);
	//		var _y = lerp(y1, y2, n);
	//		data[j] = new __follower_data_pos(_x, _y, move_x, move_y);
	//	}
	//	
	//	pos1 = pos2;
	//	x1 = x2;
	//	y1 = y2;
	//}
	//
	//data[folCount * folSpacing + 1] = new __follower_data_pos(x2, y2, move_x, move_y);
}

function follower_history_rebuild_line(x_move, y_move, data_func) {

}
#endregion