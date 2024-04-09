@tool
extends MarginContainer

var TEX_SELECT = preload("res://TextureSelect.tscn")

@export var setting_name: String:
	set(val):
		%SettingLabel.text = val.capitalize()
		setting_name = val

func _ready() -> void:
	if not Engine.is_editor_hint():
		FezSky.new_sky_loaded.connect(update_setting_value)

func update_setting_value():
	%SettingButton.text = FezSky.get(setting_name)
	%SettingButton.icon = FezSky.get_texture(FezSky.get(setting_name))
	
func _on_setting_value_changed(value: String) -> void:
	FezSky.set(setting_name, value.get_basename())
	update_setting_value()
	


func _on_setting_button_pressed() -> void:
	var selector = TEX_SELECT.instantiate()
	selector.texture_selected.connect(_on_setting_value_changed)
	get_tree().root.add_child(selector)
