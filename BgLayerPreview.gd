extends Node3D

const bg_layer_defaultmat: ShaderMaterial = preload("res://sky_layer_mat.tres")
@onready var bglayermat: ShaderMaterial = bg_layer_defaultmat.duplicate()

var index: int
var texture: Texture2D
var albedo: Color
var opacity: float
var vertical_tiling: bool

@onready var layer_sides: Array[MeshInstance3D] = [$Sky_BG_Front, $Sky_BG_Left, $Sky_BG_Back, $Sky_BG_Right]

@export var always_on_top := false
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bglayermat.render_priority = index + 1
	bglayermat.set_shader_parameter("texture_albedo", texture)
	bglayermat.set_shader_parameter("albedo", albedo)
	bglayermat.set_shader_parameter("opacity", opacity)
	bglayermat.set_shader_parameter("vertical_tiling", vertical_tiling)
	layer_sides.map(func(side: MeshInstance3D): side.material_override = bglayermat.duplicate())

func set_fog(fog_color: Color) -> void:
	layer_sides.map(func(side: MeshInstance3D): side.material_override.set_shader_parameter("albedo", fog_color))