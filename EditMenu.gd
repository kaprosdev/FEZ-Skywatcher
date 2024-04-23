extends PopupMenu

enum EDIT_MENU {
	NOTHING = 0,
	UNDO,
	REDO
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EditorState.unredo.version_changed.connect(_update_undo_redo)
	var undo_shortcut = Shortcut.new()
	undo_shortcut.events = InputMap.action_get_events("edit-undo")
	set_item_shortcut(get_item_index(EDIT_MENU.UNDO), undo_shortcut, true)
	var redo_shortcut = Shortcut.new()
	redo_shortcut.events = InputMap.action_get_events("edit-redo")
	set_item_shortcut(get_item_index(EDIT_MENU.REDO), redo_shortcut, true)
	_update_undo_redo()

func _update_undo_redo() -> void:
	var can_undo = EditorState.unredo.has_undo()
	set_item_disabled(get_item_index(EDIT_MENU.UNDO), not can_undo)
	# set_item_shortcut_disabled(get_item_index(EDIT_MENU.UNDO), not can_undo)
	var undo_text = "Undo "
	if can_undo:
		undo_text += EditorState.unredo.get_current_action_name() + " "
	set_item_text(get_item_index(EDIT_MENU.UNDO), undo_text)
	
	var can_redo = EditorState.unredo.has_redo()
	set_item_disabled(get_item_index(EDIT_MENU.REDO), not can_redo)
	# set_item_shortcut_disabled(get_item_index(EDIT_MENU.REDO), not can_redo)
	var redo_text = "Redo "
	if can_redo:
		redo_text += EditorState.unredo.get_action_name(EditorState.unredo.get_current_action() + 1) + " "
	set_item_text(get_item_index(EDIT_MENU.REDO), redo_text)

func _on_id_pressed(id: int) -> void:
	match id:
		EDIT_MENU.UNDO:
			EditorState.unredo.undo()
		EDIT_MENU.REDO:
			EditorState.unredo.redo()
