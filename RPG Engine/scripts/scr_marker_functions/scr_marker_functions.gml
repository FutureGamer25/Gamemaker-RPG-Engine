///@desc	Returns the marker instance of a given name.
///@param {String} name The name of the marker
///@return {Id.Instance}
function marker_get(name) {
	static struct = __marker_get_struct();
	return struct[$ name] ?? noone;
}

///@desc	Returns whether the marker of a given name exists.
///@param {String} name The name of the marker
///@return {Bool}
function marker_exists(name) {
	static struct = __marker_get_struct();
	return instance_exists(struct[$ name]);
}

///@desc	Registers an instance as a marker with the given name,
///			and returns whether it was successful.
///@param {String} name The name of the marker
///@param {Id.Instance} [id] The instance to register (defaults to the calling instance)
///@return {Bool}
function marker_register(name, id = other.id) {
	var struct = __marker_get_struct();
	if (instance_exists(struct[$ name])) {
		show_debug_message($"MARKER: Marker with name \"{name}\" already exists.");
		return false;
	}
	struct[$ name] = id;
	return true;
}

///@desc	Unregisters a marker instance if it is registered as the given name.
///@param {String} name The name of the marker
///@param {Id.Instance} [id] The instance to unregister (defaults to the calling instance)
function marker_unregister(name, id = other.id) {
	var struct = __marker_get_struct();
	if (struct[$ name] = id) struct_remove(struct, name);
}

///@ignore
function __marker_get_struct() {
	static struct = {};
	return struct;
}