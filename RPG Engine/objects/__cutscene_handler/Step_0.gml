if (!play) exit;

if useThreads {
	
	threadCallArr = array_filter(threadArr, function(elem, ind) {
		return !elem.paused;
	});
	
	if (autoDestroy && array_length(threadCallArr) = 0) {
		instance_destroy();
		exit;
	}
	
	__cutscene_get_data().current = id;
	
	while (array_length(threadCallArr) > 0) {
		var arr = threadCallArr;
		threadCallArr = [];
		for (var i=0; i<array_length(arr); i++) {
			callThread(arr[i]);
		}
	}
	
} else {
	
	if (autoDestroy && defaultThread.paused) {
		instance_destroy();
		exit;
	}
	
	__cutscene_get_data().current = id;
	
	callThread(defaultThread);
	
}