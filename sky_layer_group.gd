extends MeshInstance3D

@export_enum("Left", "Back", "Right", "Front") var side: int = 0
@onready var index = self.get_parent().index
@onready var texture = self.get_parent().texture

var wind_offset: float = 0.0

var texturematrix: Basis = Basis.IDENTITY

func _process(delta: float) -> void:
	if self.material_override != null:
		self.material_override.set_shader_parameter("tex_matrix", texturematrix)
		self.material_override.set_shader_parameter("opacity", 0.5)
	pass
