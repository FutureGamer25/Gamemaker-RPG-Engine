function state_machine(states_struct) constructor {
	/**@ignore*/ static enterHash = variable_get_hash("enter");
	/**@ignore*/ static leaveHash = variable_get_hash("leave");
	
	static set_state = function(state_name) {
		if (state = state_name) return;
		
		if (is_struct(struct)) {
			var func = struct_get_from_hash(struct, leaveHash);
			if (is_method(func)) func();
		}
		
		prevState = state;
		state = state_name;
		struct = states[$ state_name];
		
		if (is_struct(struct)) {
			var func = struct_get_from_hash(struct, enterHash);
			if (is_method(func)) func();
		}
	}
	
	static get_state = function() {
		return struct;
	}
	
	static get_state_name = function() {
		return state;
	}
	
	static prev_state_name = function() {
		return prevState;
	}
	
	/**@ignore*/ states = states_struct;
	/**@ignore*/ state = "";
	/**@ignore*/ prevState = "";
	/**@ignore*/ struct = undefined;
}

function state_machine_create(states_struct) {
	return new state_machine(states_struct);
}

function state_machine_set_state(machine, state_name) {
	machine.set_state(state_name);
}

function state_machine_get_state(machine) {
	return machine.get_state();
}

function state_machine_get_state_name(machine) {
	return machine.get_state_name();
}

function state_machine_prev_state_name(machine) {
	return machine.prev_state_name();
}