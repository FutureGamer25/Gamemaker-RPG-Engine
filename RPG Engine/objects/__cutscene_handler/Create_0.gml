play = false;
parentScope = id;
autoDestroy = true;
useStringVariables = true;
useThreads = false;
//defaultThread = noone; //defined below
//currentThread = noone; //defined below
threadArr = [];
threadCallArr = []; //for threads that are called during another thread
threadStack = []; //the parent list of threads for defining the cutscene

callThread = function(thread) {
	while (play) {
		var index = thread.sceneIndex;
		if (index >= array_length(thread.funcArr)) {
			thread.paused = true;
			thread.sceneIndex = 0;
			break;
		}
		
		currentThread = thread;
		var func = thread.funcArr[index];
		var param = thread.paramArr[index];
		var skip = thread.skipArr[index];
		var doBreak = thread.breakArr[index];
		
		if is_undefined(param) {
			with parentScope func();
		} else {
			var new_param = [];
			if useStringVariables {
				#region get v: variables
				for (var i=array_length(param)-1; i>=0; i--) {
					var par = param[i];
					if is_string(par) if string_copy(par, 1, 2) = "v:" {
						//feather disable once all
						par = variable_struct_get(parentScope, string_delete(par, 1, 2));
					}
					new_param[i] = par;
				}
				#endregion
			} else {
				new_param = param;
			}
			
			var scope = method_get_self(func) ?? parentScope;
			with scope script_execute_ext(method_get_index(func), new_param);
		}
		
		if skip thread.sceneIndex ++;
		if doBreak break;
	}
};

newThread = function() {
	var thread = {
		funcArr : [],
		paramArr : [],
		skipArr : [],
		breakArr : [],
		labels : {},
		sceneIndex : 0,
		paused : true
	};
	
	array_push(threadArr, thread);
	return thread;
};

playThread = function(thread) {
	thread.paused = false;
	array_push(threadCallArr, thread);
}

defaultThread = newThread();
currentThread = defaultThread;
currentThread.paused = false;
array_push(threadStack, currentThread);