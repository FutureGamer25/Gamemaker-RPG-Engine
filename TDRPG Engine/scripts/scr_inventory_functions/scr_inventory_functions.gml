#region 1d
function inv_create(size) {
	return array_create(size, -1);
}

function inv_size(inventory) {
	return array_length(inventory);
}

function inv_add_item(item, inventory) {
	var index = inv_find_empty(inventory);
	if (index = -1) return false;
	inventory[index] = item;
	return true;
}

function inv_remove_item(index, inventory) {
	inventory[index] = -1;
}

function inv_set_item(index, item, inventory) {
	inventory[index] = item;
}

function inv_get_item(index, inventory) {
	return inventory[index];
}

function inv_full(inventory) {
	return inv_find_empty(inventory) = -1;
}

function inv_find_empty(inventory) {
	var len = array_length(inventory);
	for (var i=0; i<len; i++) {
		if (inventory[i] = -1) return i;
	}
	return -1;
}

function inv_lancer(inventory) { //very important function don't remove
	array_resize(inventory, 1);
	inventory[0] = "lancer_deltarune";
}
#endregion

#region 2d
function inv_2d_create(w, h) {
	var inv = [];
	for (var i=0; i<w; i++) {
		inv[i] = array_create(h, -1);
	}
	return inv;
}

function inv_2d_width(inventory) {
	return array_length(inventory);
}

function inv_2d_height(inventory) {
	return array_length(inventory[0]);
}

function inv_2d_add_item(item, inventory) {
	var pos = inv_2d_find_empty(inventory);
	if is_undefined(pos) return false;
	inventory[pos.x][pos.y] = item;
	return true;
}

function inv_2d_remove_item(_x, _y, inventory) {
	inventory[_x][_y] = -1;
}

function inv_2d_set_item(_x, _y, item, inventory) {
	inventory[_x][_y] = item;
}

function inv_2d_get_item(_x, _y, inventory) {
	return inventory[_x][_y];
}

function inv_2d_full(inventory) {
	return is_undefined(inv_2d_find_empty(inventory));
}

function inv_2d_find_empty(inventory) {
	var w = array_length(inventory);
	var h = array_length(inventory[0]);
	for (var j=0; j<h; j++) {
		for (var i=0; i<w; i++) {
			if (inventory[i][j] = -1) return {x: i, y: j};
		}
	}
	return undefined;
}

function inv_2d_lancer(inventory) { //also very important function don't remove
	array_resize(inventory, 1);
	inventory[0] = "lancer_deltarune";
}
#endregion