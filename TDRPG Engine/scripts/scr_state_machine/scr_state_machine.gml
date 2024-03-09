function __state_machine_class(states_struct) constructor {
	/**@ignore*/ static enterHash = variable_get_hash("enter");
	/**@ignore*/ static leaveHash = variable_get_hash("leave");
	
	static set_state = function(state_name) {
		if (state != state_name) {
			var func = undefined;
			if (struct != undefined) func = struct_get_from_hash(struct, leaveHash);
			if (func != undefined) func();
			
			prevState = state;
			state = state_name;
			struct = states[$ state_name];
			
			if (struct = undefined) return;
			func = struct_get_from_hash(struct, enterHash);
			if (func != undefined) func();
		}
	}
	
	static get_state = function() {
		return struct;
	}
	
	static get_state_name = function() {
		return state;
	}
	
	static get_prev_state_name = function() {
		return prevState;
	}
	
	/**@ignore*/ states = states_struct;
	/**@ignore*/ state = "";
	/**@ignore*/ prevState = "";
	/**@ignore*/ struct = {};
}

function state_machine_create(states_struct) {
	return new __state_machine_class(states_struct);
}