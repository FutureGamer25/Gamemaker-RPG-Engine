#region item constructors
function __item(_name, _desc) constructor {
	name = _name;
	desc = _desc;
	type = "basic";
	static remove_item = function(struct) {
		var remove = struct[$ "remove"];
		if is_undefined(remove) return;
		remove();
	}
}

function __item_heal(_name, _desc, _hp) : __item(_name, _desc) constructor {
	hp = _hp;
	type = "heal";
	static run = function(struct) {
		//heal struct.member
		remove_item(struct);
	}
}

function __item_heal_all(_name, _desc, _hp) : __item(_name, _desc) constructor {
	hp = _hp;
	type = "heal_all";
	static run = function(struct) {
		//heal everyone
		remove_item(struct);
	}
}
#endregion

global.items = {
	"candy" : new __item_heal("Candy", "Good for the soul.", 5),
	"new_item" : new __item_heal_all("Unnamed", "Undescribable.", 10)
};