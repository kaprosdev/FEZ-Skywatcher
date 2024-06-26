extends Control

const ARROWS = ["▶", "◀"]
var settings_collapsed = false:
	set(val):
		$CollapserButton.text = ARROWS[1] if val else ARROWS[0]
		$SettingsContainer.visible = !val
		settings_collapsed = val

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	FezSky.new_sky_loaded.connect(sky_loaded)
	pass # Replace with function body.

func sky_loaded() -> void:
	if FezSky.sky_loaded:
		%UnloadedSkyCover.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_collapser_button_pressed() -> void:
	settings_collapsed = !settings_collapsed
