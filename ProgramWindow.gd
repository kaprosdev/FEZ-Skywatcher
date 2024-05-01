extends Control

var sky: FezSky = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	FezSky.new_sky_loaded.connect(enable_file_options)
	setup_file_shortcut(FILE_MENU.NEW, "file-new")
	setup_file_shortcut(FILE_MENU.OPEN, "file-open")
	setup_file_shortcut(FILE_MENU.SAVE, "file-save")
	setup_file_shortcut(FILE_MENU.SAVE_AS, "file-saveas")
	get_tree().auto_accept_quit = false

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		$UnsavedFileConfirmation.popup_if_necessary(func(): get_tree().quit())

func enable_file_options():
	%File.set_item_disabled(%File.get_item_index(FILE_MENU.SAVE), false)
	%File.set_item_disabled(%File.get_item_index(FILE_MENU.SAVE_AS), false)
	%File.set_item_disabled(%File.get_item_index(FILE_MENU.RELOAD), false)

func setup_file_shortcut(id: FILE_MENU, action_name: String):
	var shortcut = Shortcut.new()
	shortcut.events = InputMap.action_get_events(action_name)
	%File.set_item_shortcut(%File.get_item_index(id), shortcut, true)

enum FILE_MENU {
	NOTHING = 0,
	NEW,
	OPEN,
	SAVE,
	SAVE_AS,
	QUIT,
	RELOAD
}

func _stub():
	printerr("Functionality not yet implemented. If you're seeing this, either you built this early, or something got really messed up")

func open_sky() -> void:
	$OpenFileDialog.current_dir = $SaveFileDialog.current_dir
	$OpenFileDialog.show()

func save_sky(no_prompt: bool = false) -> void:
	if no_prompt and EditorState.loaded_sky_path != "":
		EditorState.save_sky(EditorState.loaded_sky_path)
	else:
		$SaveFileDialog.current_dir = $OpenFileDialog.current_dir
		$SaveFileDialog.current_file = FezSky.sky_name.to_lower() + ".fezsky.json"
		$SaveFileDialog.show()

func _on_file_id_pressed(id: int) -> void:
	match (id as FILE_MENU):
		FILE_MENU.NEW:
			$UnsavedFileConfirmation.popup_if_necessary(func(): %NameChangeDialog.setup_and_open(true))
		FILE_MENU.OPEN:
			$UnsavedFileConfirmation.popup_if_necessary(func(): open_sky())
		FILE_MENU.SAVE:
			save_sky(true)
		FILE_MENU.SAVE_AS:
			save_sky(false)
		FILE_MENU.RELOAD:
			$UnsavedFileConfirmation.popup_if_necessary(func(): EditorState.load_sky(EditorState.loaded_sky_path))
		FILE_MENU.QUIT:
			notify_thread_safe(NOTIFICATION_WM_CLOSE_REQUEST)

func _on_open_file_dialog_file_selected(path: String) -> void:
	$SaveFileDialog.current_dir = $OpenFileDialog.current_dir
	EditorState.load_sky(path)


func _on_save_file_dialog_file_selected(path: String) -> void:
	$OpenFileDialog.current_dir = $SaveFileDialog.current_dir
	EditorState.save_sky(path)
