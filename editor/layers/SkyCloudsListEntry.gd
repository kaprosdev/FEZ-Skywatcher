extends Control

const TEX_SELECT = preload("res://editor/settings/TextureSelect.tscn")

var cloud_index: int
var cloud_name:
	get:
		return FezSky.clouds[cloud_index] if FezSky.clouds.size() > cloud_index else "Unset"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_cloud_texture_button()
	
func update_cloud_texture_button() -> void:
	%CloudValue.text = cloud_name
	%CloudValue.icon = FezSky.get_texture(cloud_name)

func _on_cloud_value_pressed() -> void:
	var selector = TEX_SELECT.instantiate()
	selector.texture_selected.connect(_on_cloud_texture_changed)
	get_tree().root.add_child(selector)

func _on_cloud_texture_changed(value: String) -> void:
	EditorState.alter_with_methods("Change Cloud Texture", _replace_cloud.bind(value), _replace_cloud.bind(cloud_name))
	
func _replace_cloud(new_cloud: String):
	FezSky.clouds[cloud_index] = new_cloud
	EditorState.force_sky_changed()
	update_cloud_texture_button()

func _on_delete_cloud_button_pressed() -> void:
	EditorState.alter_with_methods("Delete Cloud", _remove_cloud, _reinsert_cloud.bind(cloud_name, cloud_index))

func _remove_cloud():
	FezSky.clouds.remove_at(cloud_index)
	EditorState.force_sky_changed()
	FezSky.clouds_changed.emit()

static func _reinsert_cloud(name: String, idx: int):
	FezSky.clouds.insert(idx, name)
	EditorState.force_sky_changed()
	FezSky.clouds_changed.emit()

