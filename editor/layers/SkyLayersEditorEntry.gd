extends MarginContainer

var TEX_SELECT = preload("res://editor/settings/TextureSelect.tscn")

var layer_index: int
var layer: FezSkyLayer:
	get:
		return FezSky.layers[layer_index]

func _ready() -> void:
	update_all_setting_values()

func update_all_setting_values():
	var texname = layer.name
	%NameValue.text = texname
	%NameValue.icon = FezSky.get_texture(texname)
	%InFrontValue.button_pressed = layer.in_front
	%OpacityValue.value = layer.opacity
	%FogTintValue.value = layer.fog_tint


func _on_name_texture_pressed() -> void:
	var selector = TEX_SELECT.instantiate()
	selector.texture_selected.connect(_on_name_texture_changed)
	get_tree().root.add_child(selector)

func update_layer_texture_button() -> void:
	%NameValue.text = layer.name
	%NameValue.icon = FezSky.get_texture(layer.name)

func _on_name_texture_changed(value: String) -> void:
	EditorState.alter_object(layer, "Modify Layer %s Texture" % layer_index, "name", value, [EditorState.force_sky_changed, update_layer_texture_button])

func _on_in_front_value_changed(toggled_on: bool) -> void:
	EditorState.alter_object(layer, "Modify Layer %s In Front" % layer_index, "in_front", toggled_on, [EditorState.force_sky_changed, update_in_front_no_signal])

func update_in_front_no_signal():
	%InFrontValue.set_pressed_no_signal(layer.in_front)

func _on_opacity_value_changed(value: float) -> void:
	EditorState.alter_object(layer, "Modify Layer %s Opacity" % layer_index, "opacity", value, [EditorState.force_sky_changed, update_opacity_no_signal], UndoRedo.MERGE_ENDS)

func update_opacity_no_signal():
	%OpacityValue.set_value_no_signal(layer.opacity)

func _on_fog_tint_value_changed(value: float) -> void:
	EditorState.alter_object(layer, "Modify Layer %s Fog Tint" % layer_index, "fog_tint", value, [EditorState.force_sky_changed, update_fogtint_no_signal], UndoRedo.MERGE_ENDS)

func update_fogtint_no_signal():
	%FogTintValue.set_value_no_signal(layer.fog_tint)
