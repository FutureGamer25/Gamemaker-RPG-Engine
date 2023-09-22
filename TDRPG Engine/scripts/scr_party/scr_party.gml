global.party = [];
global.partyData = {};

function party_reset_data() {
	//current members in party
	global.party = ["player"];
	
	//all member data
	global.partyData = {
		"player": {
			hp: 100,
			maxHp: 100,
			atk: 20
		},
		"jeffrey": {
			hp: 1,
			hpMax: 1,
			atk: 1
		}
	};
}

function party_get(name_or_index) {
	if is_real(name_or_index) { //get member
		if (name_or_index >= array_length(global.party)) return undefined;
		name_or_index = global.party[name_or_index];
	}
	return global.partyData[$ name_or_index];
}

function party_get_array() {
	var arr = [];
	for (var i=array_length(global.party)-1; i>=0; i--) {
	    arr[i] = global.partyData[$ global.party[i]];
	}
	return arr;
}

function party_add(name, index = array_length(global.party)) {
	array_insert(global.party, index, name);
}

function party_remove(name_or_index) {
	if is_string(name_or_index) { //find index of member
		name_or_index = array_get_index(global.party, name_or_index);
		if (name_or_index = -1) return;
	}
	array_delete(global.party, name_or_index, 1);
}

party_reset_data();