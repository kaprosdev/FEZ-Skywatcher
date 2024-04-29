extends Control

const TEX_SELECT = preload("res://editor/settings/TextureSelect.tscn")

var layer_index: int
var layer: FezSkyLayer:
	get:
		return FezSky.layers[layer_index]

func _ready() -> void:
	update_all_setting_values()
	custom_minimum_size = $LayerEntryContainer.size
	if layer_index == FezSky.layers.size() - 1:
		
		pass

func update_all_setting_values():
	var texname = layer.name
	%LayerIndexLabel.text = "#" + str(layer_index)
	update_layer_texture_button()
	update_in_front_no_signal()
	update_opacity_no_signal()
	update_fogtint_no_signal()

func _unhandled_input(event: InputEvent) -> void:
	var snapping = Input.is_action_pressed("snap_modifier")
	%ArrangeBottomButton.visible = snapping
	%ArrangeDownButton.visible = not snapping
	%ArrangeUpButton.visible = not snapping
	%ArrangeTopButton.visible = snapping

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

static func rearrange_layer(index: int, newpos: int):
	var layer_to_move = FezSky.layers[index]
	FezSky.layers.remove_at(index)
	FezSky.layers.insert(newpos, layer_to_move)
	FezSky.layers_changed.emit()
	FezSky.sky_changed.emit()

func _on_arrange_down_button_pressed() -> void:
	EditorState.alter_with_methods("Move Layer %s Down" % layer_index, rearrange_layer.bind(layer_index, layer_index - 1), rearrange_layer.bind(layer_index - 1, layer_index))
	pass # Replace with function body.


func _on_arrange_up_button_pressed() -> void:
	EditorState.alter_with_methods("Move Layer %s Up" % layer_index, rearrange_layer.bind(layer_index, layer_index + 1), rearrange_layer.bind(layer_index + 1, layer_index))
	pass # Replace with function body.


func _on_arrange_bottom_button_pressed() -> void:
	var deltapos = clampi(layer_index - FezSky.layers.size(), 0, FezSky.layers.size())
	EditorState.alter_with_methods("Move Layer %s To Bottom" % layer_index, rearrange_layer.bind(layer_index, deltapos), rearrange_layer.bind(deltapos, layer_index))
	pass # Replace with function body.


func _on_arrange_top_button_pressed() -> void:
	var deltapos = clampi(layer_index + FezSky.layers.size(), 0, FezSky.layers.size())
	EditorState.alter_with_methods("Move Layer %s To Top" % layer_index, rearrange_layer.bind(layer_index, deltapos), rearrange_layer.bind(deltapos, layer_index))
	pass # Replace with function body.
