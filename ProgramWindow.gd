extends Control

var sky: FezSky = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
	$SaveFileDialog.current_dir = $OpenFileDialog.current_dir
	$SaveFileDialog.current_file = FezSky.sky_name.to_lower() + ".fezsky.json"
	$SaveFileDialog.show()

func _on_file_id_pressed(id: int) -> void:
	match (id as FILE_MENU):
		FILE_MENU.NEW:
			FezSky.new_sky()
		FILE_MENU.OPEN:
			open_sky()
		FILE_MENU.SAVE:
			save_sky(true)
		FILE_MENU.SAVE_AS:
			save_sky(false)
		FILE_MENU.RELOAD:
			EditorState.load_sky(EditorState.loaded_sky_path)
		
	pass


func _on_open_file_dialog_file_selected(path: String) -> void:
	EditorState.load_sky(path)


func _on_save_file_dialog_file_selected(path: String) -> void:
	EditorState.save_sky(path)
