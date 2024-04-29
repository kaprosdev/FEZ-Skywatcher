extends Node

## The sky editor's universal [UndoRedo] object.
var unredo: UndoRedo

enum ArrayChange {
	APPEND,
	REPLACE,
	REMOVE
}

var loaded_sky_path = ""

## Most recent "version" of [member unredo] that was saved to disk by the user.[br]
## Used to determine whether the current version of the file is modified.
var saved_version = 0

func _init() -> void:
	unredo = UndoRedo.new()

func _ready() -> void:
	unredo.version_changed.connect(_update_window_title)
	_update_window_title()
	pass

## Update the window's title based on the current file's save status.
func _update_window_title() -> void:
	var window = get_tree().root
	if FezSky.sky_name != "":
		window.title = "%s%s - Skywatcher" % [FezSky.sky_name, ("" if unredo.get_version() == saved_version else " *")]
	elif FezSky.sky_loaded:
		window.title = "[unnamed]%s - Skywatcher" % [("" if unredo.get_version() == saved_version else " *")]
	else:
		window.title = "[no sky loaded] - Skywatcher"

## Load a sky from disk, resetting the saved status and undo history.
func load_sky(path):
	FezSky.load_sky(path)
	loaded_sky_path = path
	unredo.clear_history()
	saved_version = unredo.get_version()

## Save a sky to disk, bringing the saved status up to date.
func save_sky(path):
	FezSky.save(path)
	loaded_sky_path = path
	saved_version = unredo.get_version()
	
## Alter any property of the sky, adding that modification to the undo/redo list.
## Similar syntax to [method alter_object].
func alter_sky(action_name: String, prop: String, new_value: Variant, knockons: Array[Callable] = [], merges: UndoRedo.MergeMode = UndoRedo.MERGE_DISABLE):
	alter_object(FezSky, action_name, prop, new_value, knockons, merges)

## Alter any object's property, adding that modification to the undo/redo list.[br]
## [param knockons] is an array of functions that should be called after the property modification, regardless of whether it's being done or undone.
func alter_object(object: Variant, action_name: String, prop: String, new_value: Variant, knockons: Array[Callable] = [], merges: UndoRedo.MergeMode = UndoRedo.MERGE_DISABLE):
	unredo.create_action(action_name, merges)
	# do
	unredo.add_do_property(object, prop, new_value)
	for effect in knockons:
		unredo.add_do_method(effect)
	# undo
	unredo.add_undo_property(object, prop, object.get(prop))
	for effect in knockons:
		unredo.add_undo_method(effect)
	unredo.commit_action()
	
func alter_with_methods(action_name: String, do: Callable, undo: Callable):
	unredo.create_action(action_name)
	# do
	unredo.add_do_method(do)
	# undo
	unredo.add_undo_method(undo)
	unredo.commit_action()

func append_in_skyarray(arrname: String, newval: Variant):
	FezSky.get(arrname).push_back(newval)

func replace_in_array(arr: Array, newval: Variant, oldval: Variant):
	arr[arr.find(oldval)] = newval

## When called, emits [signal FezSky.sky_changed].[br]
## Primarily intended for use as a knockon effect for certain types of properties.
func force_sky_changed() -> void:
	FezSky.sky_changed.emit()
