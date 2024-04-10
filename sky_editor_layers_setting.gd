extends ScrollContainer

const LAYER_ENTRY = preload("res://SkyEditorLayerEntry.tscn")

@export var MAX_HEIGHT = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	FezSky.new_sky_loaded.connect(_load_layers)

func _load_layers():
	for old_layer in $LayersStack.get_children():
		old_layer.queue_free()
	for layer in FezSky.layers:
		var layer_control = LAYER_ENTRY.instantiate()
		layer_control.layer = layer
		$LayersStack.add_child(layer_control)
	custom_minimum_size = Vector2(0.0, clampf(145.0 * FezSky.layers.size(), 145.0, MAX_HEIGHT))
