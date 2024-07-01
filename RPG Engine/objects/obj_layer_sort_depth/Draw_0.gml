if (!layer_exists(layerId)) exit;

//get instances
var elements = layer_get_all_elements(layerId);
var elemLen = array_length(elements);

ds_grid_resize(grid, 2, elemLen);
var instLen = 0;

for (var i=0; i<elemLen; i++) {
	var elem = elements[i];
	if (layer_get_element_type(elem) != layerelementtype_instance) continue;
	
	var inst = layer_instance_get_instance(elem);
	if (!inst.visible) continue;
	
	ds_grid_set(grid, 0, instLen, inst);
	ds_grid_set(grid, 1, instLen, inst.y);
	instLen++;
}

//sort depths
if (instLen != elemLen) ds_grid_resize(grid, 2, instLen);
ds_grid_sort(grid, 1, true);

//draw instances
if (drawDepth) var dep = gpu_get_depth();
for (var i=0; i<instLen; i++) {
	var inst = grid[# 0, i];
	if (drawDepth) gpu_set_depth(-inst.y);
	with (inst) event_perform(ev_draw, ev_draw_normal);
}
if (drawDepth) gpu_set_depth(dep);