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
	%SettingValue.set_pressed_no_signal(FezSky.get(setting_name))
	
func _on_setting_value_changed(value: bool) -> void:
	var action_name = "%s %s" % [("Enable" if value else "Disable"), setting_name.capitalize()]
	EditorState.alter_sky(action_name, setting_name, value, [update_setting_value])
