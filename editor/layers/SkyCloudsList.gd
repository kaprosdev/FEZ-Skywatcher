extends ScrollContainer

const CLOUD_ENTRY = preload("res://editor/layers/SkyCloudsListEntry.tscn")
const TEX_SELECT = preload("res://editor/settings/TextureSelect.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	FezSky.new_sky_loaded.connect(_load_clouds)
	FezSky.clouds_changed.connect(_load_clouds)

func _load_clouds() -> void:
	for old_cloud in %CloudsStack.get_children():
		old_cloud.queue_free()
	for i in FezSky.clouds.size():
		var cloud_control = CLOUD_ENTRY.instantiate()
		cloud_control.cloud_index = i
		%CloudsStack.add_child(cloud_control)
	if FezSky.clouds.size() > 0:
		%NoCloudsEntry.visible = false
	else:
		%NoCloudsEntry.visible = true


func _on_add_cloud_button_pressed() -> void:
	var selector = TEX_SELECT.instantiate()
	selector.texture_selected.connect(_on_cloud_texture_selected)
	get_tree().root.add_child(selector)

func _on_cloud_texture_selected(value: String) -> void:
	EditorState.alter_with_methods("Add Cloud", append_cloud.bind(value), remove_appended_cloud)

func append_cloud(name: String):
	FezSky.clouds.push_back(name)
	EditorState.force_sky_changed()
	_load_clouds()

func remove_appended_cloud():
	FezSky.clouds.remove_at(FezSky.clouds.size() - 1)
	EditorState.force_sky_changed()
	_load_clouds()
