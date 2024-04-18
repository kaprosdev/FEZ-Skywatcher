extends Control

const preview_prefab = preload("res://SingleTexturePreview.tscn")

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
			$OpenFileDialog.show()
		1:
			$SaveFileDialog.show()


func _on_open_file_dialog_file_selected(path: String) -> void:
	FezSky.load(path)
	#var texturechildren = %TextureDisplay.get_children()
	#for child in texturechildren:
		#child.queue_free()
	#for texturename in sky._textures:
		#var texture_preview = preview_prefab.instantiate()
		#texture_preview.load_texture(texturename, FezSky.get_texture(texturename))
		#%TextureDisplay.add_child(texture_preview)
		
	print("Finished loading")


func _on_save_file_dialog_file_selected(path: String) -> void:
	FezSky.save(path)
	pass # Replace with function body.
