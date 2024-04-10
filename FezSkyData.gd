extends Node
class_name FezSkyData
## Data representation of a FEZ sky asset.
##

signal new_sky_loaded
signal vertical_tiling_changed
signal texture_changed(tex_field: StringName)

var sky_loaded: bool = false

## Internal lookup table of all textures associated with the 
var _textures: Dictionary

var cloud_colors: Array[Color] = []
var fog_colors: Array[Color] = []

## The name of the  Textures for the sky must be located in an adjacent folder with the same name in all lowercase.
var sky_name: String
var background: String: ## Name of the background texture for the  Must be a name of a texture in the sky's adjacent folder.
	set(texname):
		background = texname
		texture_changed.emit("background")
var wind_speed: float
var density: float
var fog_density: float
var layers: Array[FezSkyLayer] ## List of [FezSkyLayer]s to render with this 
var clouds: Array[String] ## List of names of textures to use for clouds. Must be names of textures in the sky's adjacent folder.
var shadows: String ## Name of the texture to use for shadows. Must be a name of a texture in the sky's adjacent folder.
var stars: String ## Name of the texture to use for stars. Must be a name of a texture in the sky's adjacent folder.
var cloud_tint: String
var vertical_tiling: bool: ## If true, sky layers repeat at intervals up and down the skybox. Otherwise, there is only one set of sky layers centered on the origin.
	set(val):
		vertical_tiling = val
		vertical_tiling_changed.emit()
var horizontal_scrolling: bool
var layer_base_height: float
var interlayer_vertical_distance: float
var interlayer_horizontal_distance: float
var horizontal_distance: float
var vertical_distance: float
var layer_base_spacing: float
var wind_parallax: float
var wind_distance: float
var clouds_parallax: float
var shadow_opacity: float
var foliage_shadows: bool
var no_per_face_layer_x_offset: bool
var layer_base_x_offset: float


func get_texture(name: String) -> Texture2D:
	return _textures[name.to_lower()]

func get_cloud_color(time: float) -> Color:
	return get_timed_color(time, cloud_colors)

func get_fog_color(time: float) -> Color:
	return get_timed_color(time, fog_colors)

func get_timed_color(time: float, color_arr: Array[Color]) -> Color:
	time = fposmod(time, 1.0)
	var coloridx_f: float = time * (color_arr.size() as float)
	if coloridx_f == (color_arr.size() as float):
		coloridx_f = 0.0
	var color_1: Color = color_arr[max(floori(coloridx_f), 0)]
	var color_2: Color = color_arr[min(ceili(coloridx_f), color_arr.size() - 1)]
	var color_interp: float = coloridx_f - floorf(coloridx_f)
	var the_color = color_1.lerp(color_2, color_interp)
	return the_color

func load(path) -> void:
	var file = FileAccess.open(path, FileAccess.READ)
	var file_contents = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(file_contents)
	if error != OK:
		printerr("JSON parsing failed!")
		return
	var skydata = json.data
	file.close()

	
	if not skydata.has("Name"):
		printerr("Sky has no name - cannot load any textures!")
		return
	sky_name = skydata["Name"]

	# Grab all sky textures from the adjacent folder
	var texdir = path.get_base_dir() + "\\" + sky_name.to_lower()
	var tex_folder: DirAccess = DirAccess.open(texdir)
	if tex_folder == null:
		printerr("Could not open textures folder!")
		return
	var texturedict: Dictionary = {}
	for texfilename in tex_folder.get_files():
		var texfilepath: String = texdir + "\\" + texfilename
		var tex: ImageTexture = ImageTexture.create_from_image(Image.load_from_file(texfilepath))
		texturedict[texfilename.get_basename().to_lower()] = tex
	_textures = texturedict

	# Parse sky layers
	var skylayers: Array[FezSkyLayer] = []
	for layerdata in skydata["Layers"]:
		var layer: FezSkyLayer = FezSkyLayer.new()
		layer.name = layerdata.get("Name", "")
		if not _textures.has(layer.name.to_lower()):
			printerr("A sky layer did not have a corresponding texture and will not be included!")
			continue
		layer.in_front = layerdata.get("InFront", false)
		layer.opacity = layerdata.get("Opacity", 1)
		layer.fog_tint = layerdata.get("FogTint", 0.3)
		skylayers.push_back(layer)
	layers = skylayers

	# Parse clouds
	for cloud in skydata["Clouds"]:
		if not _textures.has(cloud.to_lower()):
			printerr("A cloud did not have a corresponding texture and will not be included!")
			continue
		clouds.push_back(cloud)

	# Load up the rest of the variables
	background = skydata.get("Background", "")
	wind_speed = skydata.get("WindSpeed", 1.0)
	density = skydata.get("Density", 1.0)
	fog_density = skydata.get("FogDensity", 0.02)
	shadows = skydata.get("Shadows", "")
	stars = skydata.get("Stars", "")
	cloud_tint = skydata.get("CloudTint", "")
	vertical_tiling = skydata.get("VerticalTiling", false)
	horizontal_scrolling = skydata.get("HorizontalScrolling", false)
	layer_base_height = skydata.get("LayerBaseHeight", 0.5)
	interlayer_vertical_distance = skydata.get("InterLayerVerticalDistance", 0.1)
	interlayer_horizontal_distance = skydata.get("InterlayerHorizontalDistance", 0.1)
	horizontal_distance = skydata.get("HorizontalDistance", 0.2)
	vertical_distance = skydata.get("VerticalDistance", 0.2)
	layer_base_spacing = skydata.get("LayerBaseSpacing", 0)
	wind_parallax = skydata.get("WindParallax", 0)
	wind_distance = skydata.get("WindDistance", 0)
	clouds_parallax = skydata.get("CloudsParallax", 1.0)
	shadow_opacity = skydata.get("ShadowOpacity", 0.7)
	foliage_shadows = skydata.get("FoliageShadows", false)
	no_per_face_layer_x_offset = skydata.get("NoPerFaceLayerXOffset", false)
	layer_base_x_offset = skydata.get("LayerBaseXOffset", 0)
	
	# initialize cloud colors (necessary for layer colors even if we don't have clouds)
	if cloud_tint != "":
		var cloudtint_image = get_texture(cloud_tint).get_image()
		var cloudtint_region = cloudtint_image.get_region(Rect2i(0, cloudtint_image.get_height() / 2, cloudtint_image.get_width(), 1))
		var tintdata = cloudtint_region.get_data()
		for i in range(0, tintdata.size(), 4):
			var cloudcolor = Color(tintdata.decode_u8(i) / 255.0, tintdata.decode_u8(i+1) / 255.0, tintdata.decode_u8(i+2) / 255.0, tintdata.decode_u8(i+3) / 255.0)
			cloud_colors.push_back(cloudcolor)
	else:
		cloud_colors.push_back(Color.WHITE)
	
	# initialize fog colors
	var bgimage = get_texture(background).get_image()
	var fogregion = bgimage.get_region(Rect2i(0, bgimage.get_height() / 2, bgimage.get_width(), 1))
	var fogdata = fogregion.get_data()
	for i in range(0, fogdata.size(), 4):
		var fogcolor = Color(fogdata.decode_u8(i) / 255.0, fogdata.decode_u8(i+1) / 255.0, fogdata.decode_u8(i+2) / 255.0, fogdata.decode_u8(i+3) / 255.0)
		fog_colors.push_back(fogcolor)

	sky_loaded = true
	new_sky_loaded.emit()
