/// @function menu_stack(root_menu)
/// @description Creates a menu represented as a stack of submenus
/// @param {struct} root_menu A recursive struct which stores the properties and methods of the menu
function menu_stack(root_menu) constructor {
    /**@ignore*/ static openHash = variable_get_hash("open");
    /**@ignore*/ static closeHash = variable_get_hash("close");
	
    /// @description Opens a submenu defined as a property of the current submenu
    /// @param {string} submenu_name The name of property that contains the menu definition
    /// @param {any} parameter The argument passed into the "open" property of the new submenu
    /// @param {function} on_child_close_callback A callback to be run when the child menu closes and the menu is revisited
    static open_submenu = function(submenu_name, parameter = undefined, on_child_close_callback = undefined) {
        var submenu = current[$ submenu_name];
        if (!is_struct(submenu)) return;
		
		submenu.parent = current;
        current = submenu;
        array_push(stack, current);
        array_push(callbackStack, on_child_close_callback);
		
        var func = struct_get_from_hash(current, openHash);
        if (is_method(func)) func(self, parameter);
    }
	
    /// @description Closes the current submenu, returning to the parent menu
    /// @param {any} parameter The argument passed into the "close" property of the current submenu and the on_child_close of its parent
    static close_submenu = function(parameter = undefined) {
        if (array_length(stack) <= 1) return;
        var func = struct_get_from_hash(current, closeHash);
        if (is_method(func)) func(self, parameter);
		
        var callback = array_last(callbackStack);
        array_pop(stack);
        array_pop(callbackStack);
        current = array_last(stack);
        if (is_method(callback)) callback(self, parameter);
    }
	
    /// @description Returns the root menu of the stack
    static get_root = function() {
        return root;
    }
	
    /// @description Returns the current menu of the stack
    static get_current = function() {
        return current;
    }
	
    /// @description Calls a given method of the current menu of the stack
    /// @param {string} method_name The name of the method within the struct
    /// @param {any} parameter An argument to be passed into the called method
    static call = function(method_name, parameter = undefined) {
        var func = current[$ method_name];
        if (is_method(func)) func(self, parameter);
    }
	
    /// @description Calls a given function on all menus in the stack, beginning with the root menu
    /// @param {string} method_name The name of the method within the structs
    /// @param {any} parameter An argument to be passed into the called method
    static call_stack = function(method_name, parameter = undefined) {
		var methodHash = variable_get_hash(method_name);
        for (var i=0; i<array_length(stack); i++) {
			var func = struct_get_from_hash(stack[i], methodHash);
            if (is_method(func)) func(self, parameter);
        }
    }
	
    /**@ignore*/ root = root_menu;
    /**@ignore*/ current = root_menu;
    /**@ignore*/ stack = [root_menu];
    /**@ignore*/ callbackStack = [undefined];
}

//function menu_open_submenu(menu_stack)