layerId = layer_get_id(layerName);
if (!layer_exists(layerId)) exit;

layer_set_visible(layerId, false);
depth = layer_get_depth(layerId);