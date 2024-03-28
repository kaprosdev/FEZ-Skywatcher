extends Control

const preview_prefab = preload("res://SingleTexturePreview.tscn")

var sky: FezSky = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"VBoxContainer/TabContainer/Sky Preview".resized.connect(_on_window_resized)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if %SkyPreview.time_of_day > 1.0: %TimeDisplay.value = %SkyPreview.time_of_day - 1.0
	else: %TimeDisplay.value = %SkyPreview.time_of_day
	%TimeDisplay/ClockTimeDisplay.text = %SkyPreview.humanize_time()
	pass

func _on_window_resized() -> void:
	$"VBoxContainer/TabContainer/Sky Preview/Subviewport".size = $"VBoxContainer/TabContainer/Sky Preview".size


func _on_file_id_pressed(id: int) -> void:
	match id:
		0:
			$OpenFileDialog.show()


func _on_open_file_dialog_file_selected(path: String) -> void:
	sky = FezSky.load(path)
	var texturechildren = %TextureDisplay.get_children()
	for child in texturechildren:
		child.queue_free()
	for texturename in sky._textures:
		var texture_preview = preview_prefab.instantiate()
		texture_preview.load_texture(texturename, sky._textures[texturename])
		%TextureDisplay.add_child(texture_preview)
	
	%SkyPreview.update_sky(sky)
	print("Finished loading")
