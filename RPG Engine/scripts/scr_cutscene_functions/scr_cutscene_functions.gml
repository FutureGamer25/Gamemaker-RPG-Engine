function cutscene_create() {
	var inst = instance_create_depth(0, 0, 0, __cutscene_handler);
	inst.parentScope = method_get_self(method(self, cutscene_create));
	__cutscene_get_data().current = inst;
	return inst;
}

function cutscene_set_autodestroy(cutscene = __cutscene_get_data().current, enable) {
	cutscene.autoDestroy = enable;
}

function cutscene_destroy(cutscene = __cutscene_get_data().current) {
	if instance_exists(cutscene) {
		instance_destroy(cutscene);
	}
}

function cutscene_start(cutscene = __cutscene_get_data().current) {
	cutscene.play = true;
}

function cutscene_next(cutscene = __cutscene_get_data().current) {
	cutscene.currentThread.sceneIndex ++;
}

function cutscene_pause(cutscene = __cutscene_get_data().current) {
	cutscene.play = false;
}

function cutscene_unpause(cutscene = __cutscene_get_data().current) {
	cutscene.play = true;
}

#region wrappers
function cutscene_wrapper(getter_method = undefined, setter_method = undefined) {
	return {
		get: getter_method ?? function() { return value; },
		set: setter_method ?? function(v) { value = v; },
		value: 0
	}
}

function cutscene_wrapper_value(value) {
	var wrapper = cutscene_wrapper();
	wrapper.set(value);
}

function cutscene_wrapper_set(wrapper, value) {
	wrapper.set(value);
}

function cutscene_wrapper_get(wrapper) {
	return wrapper.get();
}
#endregion

function cutscene_use_variables(cutscene = __cutscene_get_data().current, use_variables) {
	cutscene.useStringVariables = use_variables;
}

#region internal
///@ignore
function __cutscene_get_data() {
	static data = {current: noone};
	return data;
}
#endregion