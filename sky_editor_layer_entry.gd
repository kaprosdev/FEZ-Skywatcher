@tool
extends MarginContainer

var TEX_SELECT = preload("res://TextureSelect.tscn")

var layer: FezSkyLayer

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

func _on_name_texture_changed(value: String) -> void:
	layer.name = value
	%NameValue.text = value
	%NameValue.icon = FezSky.get_texture(value)

func _on_in_front_value_changed(toggled_on: bool) -> void:
	layer.in_front = toggled_on

func _on_opacity_value_changed(value: float) -> void:
	layer.opacity = value

func _on_fog_tint_value_changed(value: float) -> void:
	layer.fog_tint = value
