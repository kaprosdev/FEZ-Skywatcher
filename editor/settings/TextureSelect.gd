extends Window

signal texture_selected(tex_name: String)

func _init() -> void:
	visible = false
	force_native = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true
	if FezSky._textures != null:
		for tex_name in FezSky._textures:
			%ItemList.add_item(tex_name, FezSky._textures[tex_name])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func select_texture(index: int = 0) -> void:
	texture_selected.emit(%ItemList.get_item_text(%ItemList.get_selected_items()[0]))
	self.queue_free()

func clear_texture() -> void:
	texture_selected.emit("")
	self.queue_free()

func _on_close_requested() -> void:
	self.queue_free()
