@tool
extends MarginContainer

@export var setting_name: String:
	set(val):
		%SettingLabel.text = val.capitalize()
		setting_name = val

func _ready() -> void:
	if not Engine.is_editor_hint():
		FezSky.new_sky_loaded.connect(update_setting_value)

func update_setting_value():
	%SettingValue.button_pressed = FezSky.get(setting_name)
	
func _on_setting_value_changed(value: bool) -> void:
	FezSky.set(setting_name, value)
