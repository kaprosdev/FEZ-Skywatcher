extends Control

var sky: FezSky = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_file_id_pressed(id: int) -> void:
	match id:
		0:
			$OpenFileDialog.current_dir = $SaveFileDialog.current_dir
			$OpenFileDialog.show()
		1:
			$SaveFileDialog.current_dir = $OpenFileDialog.current_dir
			$SaveFileDialog.current_file = FezSky.sky_name.to_lower() + ".fezsky.json"
			$SaveFileDialog.show()


func _on_open_file_dialog_file_selected(path: String) -> void:
	FezSky.load(path)
		
	print("Finished loading")


func _on_save_file_dialog_file_selected(path: String) -> void:
	FezSky.save(path)
	pass # Replace with function body.
