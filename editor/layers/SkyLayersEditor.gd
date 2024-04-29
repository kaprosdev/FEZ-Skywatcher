extends Container

const LAYER_ENTRY = preload("res://editor/layers/SkyLayersEditorEntry.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	FezSky.new_sky_loaded.connect(_load_layers)
	FezSky.layers_changed.connect(_load_layers)

func _load_layers():
	for old_layer in %LayersStack.get_children():
		old_layer.queue_free()
	for i in FezSky.layers.size():
		var layer_control = LAYER_ENTRY.instantiate()
		layer_control.layer_index = FezSky.layers.size() - 1 - i
		%LayersStack.add_child(layer_control)
	if FezSky.layers.size() > 0:
		%NoLayersEntry.visible = false
	else:
		%NoLayersEntry.visible = true
