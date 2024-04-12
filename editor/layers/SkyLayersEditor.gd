extends Container

const LAYER_ENTRY = preload("res://editor/layers/SkyLayersEditorEntry.tscn")

@export var MAX_HEIGHT = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	FezSky.new_sky_loaded.connect(_load_layers)

func _load_layers():
	for old_layer in %LayersStack.get_children():
		old_layer.queue_free()
	for i in FezSky.layers.size():
		var layer_control = LAYER_ENTRY.instantiate()
		layer_control.layer_index = i
		%LayersStack.add_child(layer_control)
	if FezSky.layers.size() > 0:
		%NoLayersEntry.visible = false
		# custom_minimum_size = Vector2(0.0, clampf(145.0 * FezSky.layers.size(), 145.0, MAX_HEIGHT))
	else:
		%NoLayersEntry.visible = true
