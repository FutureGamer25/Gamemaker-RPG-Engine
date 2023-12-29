function depth_sort_set_layer(layer_name = "depth", draw_depth = false) {
	if (!instance_exists(obj_layer_sort_depth)) instance_create_depth(0, 0, 0, obj_layer_sort_depth);
	obj_layer_sort_depth.layerName = layer_name;
	obj_layer_sort_depth.drawDepth = draw_depth;
}