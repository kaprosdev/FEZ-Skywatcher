extends Control


@export_node_path("ItemList") var _texture_listing: NodePath
var texture_listing: ItemList:
	get:
		return get_node(_texture_listing)
	
@export_node_path("Button") var _delete_button: NodePath
var delete_button: Button:
	get:
		return get_node(_delete_button)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	FezSky.new_sky_loaded.connect(reload_textures)
	FezSky.sky_changed.connect(reload_textures)
	pass # Replace with function body.


func reload_textures() -> void:
	texture_listing.clear()
	for texturename in FezSky._textures:
		texture_listing.add_item(texturename, FezSky.get_texture(texturename))


func _on_add_texture_button_pressed() -> void:
	$AddTextureFileDialog.show()


func _on_open_texture_dialog_file_selected(path: String) -> void:
	var newtex_img := Image.load_from_file(path)
	FezSky.add_texture(path.get_file().get_basename().to_lower(), ImageTexture.create_from_image(newtex_img))


func _on_texture_listing_multi_selected(index: int, selected: bool) -> void:
	print("multiselect triggered! " + str(index) + ": " + str(selected))
	delete_button.disabled = not texture_listing.is_anything_selected()
	pass # Replace with function body.


func _on_texture_listing_empty_clicked(at_position: Vector2, mouse_button_index: int) -> void:
	texture_listing.deselect_all()
	delete_button.disabled = not texture_listing.is_anything_selected()
	pass # Replace with function body.
