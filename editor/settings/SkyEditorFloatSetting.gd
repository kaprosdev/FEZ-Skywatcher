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
	%SettingValue.set_value_no_signal(FezSky.get(setting_name))
	
func _on_setting_value_changed(value: float) -> void:
	var action_name = "Modify %s" % setting_name.capitalize()
	EditorState.alter_sky(action_name, setting_name, value, [update_setting_value], UndoRedo.MERGE_ENDS)
