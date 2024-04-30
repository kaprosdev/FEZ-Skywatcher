extends Node
class_name FezSkyData
## Data representation of a FEZ sky asset.
##

const MISSING_TEXTURE = preload("res://missing_texture.svg")
const DEFAULTSKYBG = preload("res://simpleskybg.tres")

signal new_sky_loaded
signal sky_changed
signal clouds_changed
signal layers_changed

var sky_loaded: bool = false

## Internal lookup table of all textures associated with the 
var _textures: Dictionary = {}

var cloud_colors: Array[Color] = []
var fog_colors: Array[Color] = []

## The name of the  Textures for the sky must be located in an adjacent folder with the same name in all lowercase.
var sky_name: String
var background: String: ## Name of the background texture for the  Must be a name of a texture in the sky's adjacent folder.
	set(texname):
		background = texname
		init_fog_colors()
		sky_changed.emit()
var wind_speed: float
var density: float
var fog_density: float
var layers: Array[FezSkyLayer] ## List of [FezSkyLayer]s to render with this 
var clouds: Array[String] ## List of names of textures to use for clouds. Must be names of textures in the sky's adjacent folder.
var shadows: String: ## Name of the texture to use for shadows. Must be a name of a texture in the sky's adjacent folder.
	set(texname):
		shadows = texname
		sky_changed.emit()
var stars: String ## Name of the texture to use for stars. Must be a name of a texture in the sky's adjacent folder.
var cloud_tint: String:
	set(texname):
		cloud_tint = texname
		init_cloud_colors()
		sky_changed.emit()
var vertical_tiling: bool: ## If true, sky layers repeat at intervals up and down the skybox. Otherwise, there is only one set of sky layers centered on the origin.
	set(val):
		vertical_tiling = val
		sky_changed.emit()
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


func get_texture(texname: String) -> Texture2D:
	if _textures.has(texname.to_lower()):
		return _textures[texname.to_lower()]
	else:
		return MISSING_TEXTURE

func add_texture(texname: String, texture: Texture2D) -> void:
	_textures[texname] = texture
	sky_changed.emit()

func remove_texture(texname: String, should_emit: bool = true) -> void:
	_textures.erase(texname.to_lower())
	if should_emit:
		sky_changed.emit()

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

func new_sky() -> void:
	_textures = {"skyback": DEFAULTSKYBG}
	for layer in layers:
		layer.free()
	layers = []
	clouds = []
	background = "skyback"
	wind_speed = 1.0
	density = 1.0
	fog_density = 0.02
	shadows = ""
	stars = ""
	cloud_tint = ""
	vertical_tiling = false
	horizontal_scrolling = false
	layer_base_height = 0.5
	interlayer_vertical_distance = 0.1
	interlayer_horizontal_distance = 0.1
	horizontal_distance = 0.2
	vertical_distance = 0.2
	layer_base_spacing = 0
	wind_parallax = 0
	wind_distance = 0
	clouds_parallax = 1.0
	shadow_opacity = 0.7
	foliage_shadows = false
	no_per_face_layer_x_offset = false
	layer_base_x_offset = 0
	
	init_cloud_colors()
	init_fog_colors()
	
	sky_loaded = true
	new_sky_loaded.emit()

func load_sky(path) -> void:
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

	for layer in layers:
		layer.free()
	# Parse sky layers
	layers = []
	for layerdata in skydata["Layers"]:
		var layer: FezSkyLayer = FezSkyLayer.new()
		layer.name = layerdata.get("Name", "")
		if not _textures.has(layer.name.to_lower()):
			printerr("A sky layer did not have a corresponding texture and will not be included!")
			continue
		layer.in_front = layerdata.get("InFront", false)
		layer.opacity = layerdata.get("Opacity", 1)
		layer.fog_tint = layerdata.get("FogTint", 0.3)
		layers.push_back(layer)

	# Parse clouds
	clouds = []
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
	init_cloud_colors()
	
	# initialize fog colors
	init_fog_colors()

	sky_loaded = true
	new_sky_loaded.emit()

func save(path: String):
	# pass
	
	var save_dictionary = {
		"Name": sky_name,
		"Background": background,
		"WindSpeed": wind_speed,
		"Density": density,
		"FogDensity": fog_density,
		"Layers": layers.map(func(layer: FezSkyLayer): return layer.to_dictionary()),
		"Clouds": clouds,
		"Shadows": shadows,
		"Stars": stars,
		"CloudTint": cloud_tint,
		"VerticalTiling": vertical_tiling,
		"HorizontalScrolling": horizontal_scrolling,
		"LayerBaseHeight": layer_base_height,
		"InterLayerVerticalDistance": interlayer_vertical_distance,
		"InterLayerHorizontalDistance": interlayer_horizontal_distance,
		"HorizontalDistance": horizontal_distance,
		"VerticalDistance": vertical_distance,
		"LayerBaseSpacing": layer_base_spacing,
		"WindParallax": wind_parallax,
		"WindDistance": wind_distance,
		"CloudsParallax": clouds_parallax,
		"ShadowOpacity": shadow_opacity,
		"FoliageShadows": foliage_shadows,
		"NoPerFaceLayerXOffset": no_per_face_layer_x_offset,
		"LayerBaseXOffset": layer_base_x_offset
	}
	
	var savejson = JSON.stringify(save_dictionary, "  ", false)
	print(savejson)
	var save = FileAccess.open(path, FileAccess.WRITE)
	save.store_string(savejson)
	save.close()
	
	var textures_folder_path = path.get_base_dir() + "/" + sky_name.to_lower()
	if not DirAccess.dir_exists_absolute(textures_folder_path):
		DirAccess.make_dir_recursive_absolute(textures_folder_path)
	for texname in _textures.keys():
		_textures[texname].get_image().save_png(textures_folder_path + "/" + texname.to_lower() + ".png")
		
	FezSky.new_sky_loaded.emit()
	return

func init_cloud_colors():
	cloud_colors = []
	if cloud_tint != "":
		var cloudtint_image = get_texture(cloud_tint).get_image()
		var cloudtint_region = cloudtint_image.get_region(Rect2i(0, cloudtint_image.get_height() / 2, cloudtint_image.get_width(), 1))
		var tintdata = cloudtint_region.get_data()
		for i in range(0, tintdata.size(), 4):
			var cloudcolor = Color(tintdata.decode_u8(i) / 255.0, tintdata.decode_u8(i+1) / 255.0, tintdata.decode_u8(i+2) / 255.0, tintdata.decode_u8(i+3) / 255.0)
			cloud_colors.push_back(cloudcolor)
	else:
		cloud_colors.push_back(Color.WHITE)
	
func init_fog_colors():
	var bgimage = get_texture(background).get_image()
	var fogregion = bgimage.get_region(Rect2i(0, bgimage.get_height() / 2, bgimage.get_width(), 1))
	var fogdata = fogregion.get_data()
	fog_colors = []
	for i in range(0, fogdata.size(), 4):
		var fogcolor = Color(fogdata.decode_u8(i) / 255.0, fogdata.decode_u8(i+1) / 255.0, fogdata.decode_u8(i+2) / 255.0, fogdata.decode_u8(i+3) / 255.0)
		fog_colors.push_back(fogcolor)
