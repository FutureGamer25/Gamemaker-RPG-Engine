//item_run("candy", {member: 0, inv: global.inv, remove});
function item_run(item_key, struct = {}) {
	global.items[$ item_key].run(struct);
}

function item_struct(item_key) {
	return global.items[$ item_key];
}

#region inventory
function inv_get_item_struct(index, inventory) {
	var item = inv_get_item(index, inventory);
	return (item = -1) ? -1 : item_struct(item);
}

function inv_use_item(index, party_member, inventory) {
	var item = inv_get_item(index, inventory);
	if (item = -1) return false;
	item_run(item, {
		member: party_member,
		inv: inventory,
		index: index,
		remove: function() { inv_remove_item(index, inv); }
	});
	return true;
}
#endregion

#region inventory 2d
function inv_2d_get_item_struct(_x, _y, inventory) {
	var item = inv_2d_get_item(_x, _y, inventory);
	return (item = -1) ? -1 : item_struct(item);
}

function inv_2d_use_item(_x, _y, party_member, inventory) {
	var item = inv_2d_get_item(_x, _y, inventory);
	if (item = -1) return false;
	item_run(item, {
		member: party_member,
		inv: inventory,
		x: _x,
		y: _y,
		remove: function() { inv_2d_remove_item(x, y, inv); }
	});
	return true;
}
#endregion