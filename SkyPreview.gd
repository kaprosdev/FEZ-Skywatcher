extends Control

const BG_Layer_Prefab = preload("res://BgLayerPreview.tscn")

const BASE_DAY_LENGTH = (24 * 60 * 60) / 260.0
const BASE_DAY_FACTOR = inverse_lerp(0, BASE_DAY_LENGTH, 1.0)
const DAY_LENGTH_MULT = 20.0
var time_of_day: float = 0.5

const DEBUG_ALBEDOS_TEMP = [Color.MAGENTA, Color.FOREST_GREEN, Color.YELLOW]
var bglayers: Array[Node3D] = []

const PREVIEW_MOVE_SPEED = 1.0
var level_size: Vector3 = Vector3(60, 54, 60)
var camera_radius: float = 40.0

@export_node_path("Camera3D") var layer_camera_path: NodePath
@onready var layer_camera: Camera3D = get_node(layer_camera_path)
@export_node_path("Node3D") var camera_center_path: NodePath
@onready var camera_center: Node3D = get_node(camera_center_path)
var rotating := false
var current_rotation := 0.0

var sideOffset: float = 0.0
var lastCamSide: float = 0.0
var sinceReached: float = 0.0

@export_node_path("Node3D") var bg_layers_root_path: NodePath
@onready var bglayers_root: Node3D = get_node(bg_layers_root_path)
var layers_loaded: bool = false

var layer_meshes: Array[Node]:
	get:
		if layers_loaded:
			return bglayers.map(func(c): return c.get_children()).reduce(func(accum, next): return accum + next)
		else:
			return []

@export var sky_bg_mat: ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resized.connect(_on_window_resized)
	pass # Replace with function body.
	
func update_sky(new_sky: FezSky):
	sky_bg_mat.set_shader_parameter("sky_texture", FezSky.active.get_texture(FezSky.active.background))
	if bglayers.size() > 0:
		layers_loaded = false
		for layer in bglayers:
			layer.queue_free()
	bglayers = []
	for i in FezSky.active.layers.size():
		var layer_definition = FezSky.active.layers[i]
		var layer = BG_Layer_Prefab.instantiate()
		var layer_tex = FezSky.active.get_texture(layer_definition.name)
		layer.index = i
		layer.texture = layer_tex
		layer.albedo = DEBUG_ALBEDOS_TEMP[i % DEBUG_ALBEDOS_TEMP.size()]
		bglayers.push_back(layer)
		bglayers_root.add_child(layer)
	layers_loaded = true
		

func _on_window_resized() -> void:
	$"3DWorldViewport".size = self.size

func _unhandled_input(event: InputEvent) -> void:
	if not rotating:
		if Input.is_action_just_pressed("preview_lt"):
			rotating = true
			current_rotation += 90
		if Input.is_action_just_pressed("preview_rt"):
			rotating = true
			current_rotation -= 90
		if rotating:
			bglayers_root.top_level = true
			var rotate_tween = create_tween()
			rotate_tween.set_ease(Tween.EASE_OUT)
			rotate_tween.set_trans(Tween.TRANS_QUART)
			rotate_tween.tween_property(camera_center, "rotation_degrees:y", current_rotation, 0.5)
			rotate_tween.tween_callback(func(): rotating = false)
			rotate_tween.tween_callback(func(): bglayers_root.top_level = false)
		
func print_matrix(proj, matsize):
	var tablestring = "[table=" + str(matsize) + "]"
	for y in matsize:
		for x in matsize:
			tablestring += "[cell]" + str(proj[x][y]) + "[/cell]"
	tablestring += "[/table]"
	print_rich(tablestring)

			
func get_inv_view_matrix_right() -> Vector3:
	var inverse = layer_camera.get_camera_transform().inverse().basis.x
	return layer_camera.get_camera_transform().inverse().basis.x


func humanize_time():
	var currtime = time_of_day
	if time_of_day > 1.0: currtime -= 1.0
	
	var total_minutes = (currtime * 86400) / 60
	var hours = floori(total_minutes / 60.0)
	var minutes = floori(fmod(total_minutes, 60.0))
	return str(hours).lpad(2,"0") + ":" + str(minutes).lpad(2, "0")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_of_day += (delta / BASE_DAY_LENGTH) * DAY_LENGTH_MULT
	if time_of_day > 1.5:
		time_of_day -= 1.0
	sky_bg_mat.set_shader_parameter("time_of_day", time_of_day)
	
	$numlabel.text = str(layer_camera.global_position)
	
	if time_of_day > 1.0: $TimeDisplay.value = time_of_day - 1.0
	else: $TimeDisplay.value = time_of_day
	$TimeDisplay/ClockTimeDisplay.text = humanize_time()
	
	if not rotating:
		sinceReached += delta
	else:
		sinceReached = 0.0


func _physics_process(delta: float) -> void:
	if not rotating:
		if Input.is_action_pressed("preview_up"):
			camera_center.position.y += PREVIEW_MOVE_SPEED
		if Input.is_action_pressed("preview_down"):
			camera_center.position.y -= PREVIEW_MOVE_SPEED
		if Input.is_action_pressed("preview_right"):
			camera_center.position += camera_center.transform.basis.x * PREVIEW_MOVE_SPEED
		if Input.is_action_pressed("preview_left"):
			camera_center.position -= camera_center.transform.basis.x * PREVIEW_MOVE_SPEED
	
	# pass
	
	# ResizeLayers()
	if FezSky.active == null or bglayers.size() == 0:
		return
	# var viewScale: float = self.size.x / 1280.0
	var viewScale: float = 1.0
	var vector: Vector3 = camera_center.global_position
	var num7: float = (vector - level_size / 2.0).dot(get_inv_view_matrix_right())
	var num8: float = vector.y - level_size.y / 2.0 - layer_camera.v_offset
	if FezSky.active.no_per_face_layer_x_offset:
		sideOffset = num7
	elif not rotating:
		if sinceReached > 0.45:
			sideOffset -= lastCamSide - num7
		lastCamSide = num7
	bglayers_root.scale = Vector3(1, 5, 1) * camera_radius * 2.0 / viewScale
	bglayers_root.position = Vector3(0.0, 0.0, 0.0)
	for skyLayerMesh in layer_meshes:
		var num10: float = skyLayerMesh.index / (1.0 if bglayers.size() == 1 else (bglayers.size() - 1.0))
		var num12: float = bglayers_root.scale.x / (float(skyLayerMesh.texture.get_width()) / 16.0)
		var num13: float = bglayers_root.scale.y / (float(skyLayerMesh.texture.get_height()) / 16.0)
		
		$numlabel.text = "(" + str(skyLayerMesh.texture.get_width() / 16.0) + ", " + str(num8 / skyLayerMesh.texture.get_height() / 16.0) + ")"
		var vector2: Vector2 = Vector2(sideOffset / (float(skyLayerMesh.texture.get_width()) / 16.0), num8 / (float(skyLayerMesh.texture.get_height()) / 16.0))
		
		var vector3: Vector2
		var part1 = (0.0 if FezSky.active.no_per_face_layer_x_offset else (float(skyLayerMesh.side) / 4.0))
		var part2 = (vector2.x * FezSky.active.horizontal_distance)
		var part3 = (vector2.x * (FezSky.active.interlayer_horizontal_distance * num10))
		var part4 = (-skyLayerMesh.wind_offset * FezSky.active.wind_distance)
		var part5 = (-skyLayerMesh.wind_offset * (FezSky.active.wind_parallax * num10))
		vector3.x = part1 + FezSky.active.layer_base_x_offset + part2 + part3 + part4 + part5
		if not FezSky.active.vertical_tiling: num10 -= 0.5
		vector3.y = FezSky.active.layer_base_height + (num10 * FezSky.active.layer_base_spacing) + (-(vector2.y) * FezSky.active.vertical_distance) + (-num10 * (FezSky.active.interlayer_vertical_distance * vector2.y))
		skyLayerMesh.texturematrix = Basis(Vector3(-num12, 0.0, -vector3.x + num12 / 2.0), Vector3(0.0, num13, vector3.y - num13 / 2.0), Vector3(0.0, 0.0, 1.0))
		
