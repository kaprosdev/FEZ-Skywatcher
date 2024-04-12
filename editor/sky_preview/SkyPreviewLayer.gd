extends Node3D

const bg_layer_defaultmat: ShaderMaterial = preload("res://editor/sky_preview/SkyLayer_Material.tres")
@onready var bglayermat: ShaderMaterial = bg_layer_defaultmat.duplicate()

var index: int
var texture_name: String:
	set(val):
		texture_name = val
		texture = FezSky.get_texture(texture_name)
var texture: Texture2D
var albedo: Color = Color.MAGENTA
var opacity: float

@onready var layer_sides: Array[MeshInstance3D] = [$Sky_BG_Front, $Sky_BG_Left, $Sky_BG_Back, $Sky_BG_Right]

var always_on_top := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bglayermat.render_priority = index + (100 if always_on_top else 1)
	bglayermat.set_shader_parameter("texture_albedo", texture)
	bglayermat.set_shader_parameter("albedo", albedo)
	bglayermat.set_shader_parameter("opacity", opacity)
	bglayermat.set_shader_parameter("vertical_tiling", FezSky.vertical_tiling)
	layer_sides.map(func(side: MeshInstance3D): side.material_override = bglayermat.duplicate())

func update_vertical_tiling():
	layer_sides.map(func(side: MeshInstance3D): side.material_override.set_shader_parameter("vertical_tiling", FezSky.vertical_tiling))

func set_fog(fog_color: Color) -> void:
	layer_sides.map(func(side: MeshInstance3D): side.material_override.set_shader_parameter("albedo", fog_color))
