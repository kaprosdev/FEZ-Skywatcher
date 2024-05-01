extends Window

var is_new_sky: bool = false


func _ready() -> void:
	hide()
	force_native = true

func setup_and_open(new_sky: bool = false) -> void:
	is_new_sky = new_sky
	show()
	if is_new_sky:
		%NameEdit.text = ""
		%ChangeWarningLabel.visible = false
	else:
		%NameEdit.text = FezSky.sky_name
		%ChangeWarningLabel.visible = true

func _on_name_edit_text_changed(new_text: String) -> void:
	if new_text == "":
		%OKButton.disabled = true
	else:
		%OKButton.disabled = false

func _on_cancel_button_pressed() -> void:
	hide()

static func change_sky_name(new_name: String):
	FezSky.sky_name = new_name
	EditorState._update_window_title()

func _on_ok_button_pressed() -> void:
	if is_new_sky:
		FezSky.sky_name = %NameEdit.text
		EditorState.new_sky()
	else:
		EditorState.alter_with_methods("Change Sky Name", change_sky_name.bind(%NameEdit.text), change_sky_name.bind(FezSky.sky_name))
	hide()
	
