extends Control

const BASE_DAY_LENGTH = (24 * 60 * 60) / 260.0
const BASE_DAY_FACTOR = inverse_lerp(0, BASE_DAY_LENGTH, 1.0)
const DAY_LENGTH_MULT = 20.0
var time_of_day: float = 0.5

const PREVIEW_MOVE_SPEED = 0.1
var preview_pos: Vector2 = Vector2.ZERO

var sky: FezSky = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func update_sky(new_sky: FezSky):
	sky = new_sky
	$Background.material.set_shader_parameter("sky_texture", sky._textures[sky.background.to_lower()])
	pass


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
	$Background.material.set_shader_parameter("time_of_day", time_of_day)


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("preview_up"):
		preview_pos.y += PREVIEW_MOVE_SPEED
	if Input.is_action_pressed("preview_down"):
		preview_pos.y -= PREVIEW_MOVE_SPEED
	if Input.is_action_pressed("preview_right"):
		preview_pos.x += PREVIEW_MOVE_SPEED
	if Input.is_action_pressed("preview_left"):
		preview_pos.x -= PREVIEW_MOVE_SPEED
