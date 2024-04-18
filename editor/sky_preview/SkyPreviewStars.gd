extends Node3D

const stars_defaultmat: ShaderMaterial = preload("res://editor/sky_preview/SkyStars_Material.tres")
@onready var starsmat: ShaderMaterial = stars_defaultmat.duplicate()

var index: float = 0.0
var texture_name: String:
	set(val):
		texture_name = val
		texture = FezSky.get_texture(texture_name)
var texture: Texture2D
var opacity: float = 1.0:
	set(new_opacity):
		if is_node_ready():
			layer_sides.map(func(side: MeshInstance3D): side.material_override.set_shader_parameter("opacity", new_opacity))

@onready var layer_sides: Array[MeshInstance3D] = [$Sky_BG_Front, $Sky_BG_Left, $Sky_BG_Back, $Sky_BG_Right]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# starsmat.render_priority =
	starsmat.set_shader_parameter("texture_albedo", texture)
	starsmat.set_shader_parameter("opacity", opacity)
	layer_sides.map(func(side: MeshInstance3D): side.material_override = starsmat.duplicate())
