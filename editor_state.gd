extends Node

var unredo: UndoRedo

var saved_version = 0

func _init() -> void:
	unredo = UndoRedo.new()

func _ready() -> void:
	unredo.version_changed.connect(_update_window_title)
	pass
	
func _update_window_title() -> void:
	var window = get_tree().root
	if FezSky.sky_name != "":
		window.title = "%s%s - Skywatcher" % [FezSky.sky_name, ("" if unredo.get_version() == saved_version else " *")]
	elif FezSky.sky_loaded:
		window.title = "[unnamed]%s - Skywatcher" % [("" if unredo.get_version() == saved_version else " *")]
	else:
		window.title = "[no sky loaded] - Skywatcher"

func load_sky(path):
	FezSky.load_sky(path)
	unredo.clear_history()
	saved_version = unredo.get_version()


func save_sky(path):
	FezSky.save(path)
	saved_version = unredo.get_version()
	

func alter_sky(action_name, prop, new_value, knockons: Array[Callable] = [], merges: UndoRedo.MergeMode = UndoRedo.MERGE_DISABLE):
	alter_object(FezSky, action_name, prop, new_value, knockons, merges)

func alter_object(object, action_name, prop, new_value, knockons: Array[Callable] = [], merges: UndoRedo.MergeMode = UndoRedo.MERGE_DISABLE):
	unredo.create_action(action_name, merges)
	unredo.add_do_property(object, prop, new_value)
	for effect in knockons:
		unredo.add_do_method(effect)
	unredo.add_undo_property(object, prop, object.get(prop))
	for effect in knockons:
		unredo.add_undo_method(effect)
	unredo.commit_action()

func force_sky_changed() -> void:
	FezSky.sky_changed.emit()
