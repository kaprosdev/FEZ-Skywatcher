extends AcceptDialog

var active_callback: Callable

func _ready() -> void:
	add_button("Don't Save", true, "dontsave")
	add_cancel_button("Cancel")
	force_native = true

func popup_if_necessary(callback: Callable):
	if not EditorState.saved_up_to_date:
		dialog_text = "Do you want to save changes to %s?" % FezSky.sky_name
		active_callback = callback
		show()
	else:
		callback.call()

func _on_save_button() -> void:
	if EditorState.loaded_sky_path != "":
		EditorState.save_sky(EditorState.loaded_sky_path)
		active_callback.call()
	else:
		$HelperSaveFileDialog.current_dir = $"../OpenFileDialog".current_dir
		$HelperSaveFileDialog.current_file = FezSky.sky_name.to_lower() + ".fezsky.json"
		$HelperSaveFileDialog.show()

func _on_other_button(action: StringName) -> void:
	if action == "dontsave":
		active_callback.call()
		hide()

func _on_save_file_dialog_file_selected(path: String) -> void:
	$"../OpenFileDialog".current_dir = $HelperSaveFileDialog.current_dir
	$"../SaveFileDialog".current_dir = $HelperSaveFileDialog.current_dir
	EditorState.save_sky(path)
	active_callback.call()
