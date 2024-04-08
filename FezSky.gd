extends Object
class_name FezSky
## Data representation of a FEZ sky asset.
##

static var active: FezSky

## Internal lookup table of all textures associated with the sky.
var _textures: Dictionary

## The name of the sky. Textures for the sky must be located in an adjacent folder with the same name in all lowercase.
var name: String
var background: String ## Name of the background texture for the sky. Must be a name of a texture in the sky's adjacent folder.
var wind_speed: float
var density: float
var fog_density: float
var layers: Array[FezSkyLayer] ## List of [FezSkyLayer]s to render with this sky.
var clouds: Array[String] ## List of names of textures to use for clouds. Must be names of textures in the sky's adjacent folder.
var shadows: String ## Name of the texture to use for shadows. Must be a name of a texture in the sky's adjacent folder.
var stars: String ## Name of the texture to use for stars. Must be a name of a texture in the sky's adjacent folder.
var cloud_tint: String
var vertical_tiling: bool ## If true, sky layers repeat at intervals up and down the skybox. Otherwise, there is only one set of sky layers centered on the origin.
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

func get_texture(name: String):
	return _textures[name.to_lower()]
	
func get_num6():
	return

static func load(path) -> FezSky:
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
	var sky: FezSky = FezSky.new()
	sky.name = skydata["Name"]

	# Grab all sky textures from the adjacent folder
	var texdir = path.get_base_dir() + "\\" + sky.name.to_lower()
	var tex_folder: DirAccess = DirAccess.open(texdir)
	if tex_folder == null:
		printerr("Could not open textures folder!")
		return
	var texturedict: Dictionary = {}
	for texfilename in tex_folder.get_files():
		var texfilepath: String = texdir + "\\" + texfilename
		var tex: ImageTexture = ImageTexture.create_from_image(Image.load_from_file(texfilepath))
		texturedict[texfilename.get_basename().to_lower()] = tex
	sky._textures = texturedict

	# Parse sky layers
	var skylayers: Array[FezSkyLayer] = []
	for layerdata in skydata["Layers"]:
		var layer: FezSkyLayer = FezSkyLayer.new()
		layer.name = layerdata.get("Name", "")
		if not sky._textures.has(layer.name.to_lower()):
			printerr("A sky layer did not have a corresponding texture and will not be included!")
			continue
		layer.in_front = layerdata.get("InFront", false)
		layer.opacity = layerdata.get("Opacity", 1)
		layer.fog_tint = layerdata.get("FogTint", 0.3)
		skylayers.push_back(layer)
	sky.layers = skylayers

	# Parse clouds
	for cloud in skydata["Clouds"]:
		if not sky._textures.has(cloud.to_lower()):
			printerr("A cloud did not have a corresponding texture and will not be included!")
			continue
		sky.clouds.push_back(cloud)

	# Load up the rest of the variables
	sky.background = skydata.get("Background", "")
	sky.wind_speed = skydata.get("WindSpeed", 1.0)
	sky.density = skydata.get("Density", 1.0)
	sky.fog_density = skydata.get("FogDensity", 0.02)
	sky.shadows = skydata.get("Shadows", "")
	sky.stars = skydata.get("Stars", "")
	sky.cloud_tint = skydata.get("CloudTint", "")
	sky.vertical_tiling = skydata.get("VerticalTiling", false)
	sky.horizontal_scrolling = skydata.get("HorizontalScrolling", false)
	sky.layer_base_height = skydata.get("LayerBaseHeight", 0.5)
	sky.interlayer_vertical_distance = skydata.get("InterLayerVerticalDistance", 0.1)
	sky.interlayer_horizontal_distance = skydata.get("InterlayerHorizontalDistance", 0.1)
	sky.horizontal_distance = skydata.get("HorizontalDistance", 0.2)
	sky.vertical_distance = skydata.get("VerticalDistance", 0.2)
	sky.layer_base_spacing = skydata.get("LayerBaseSpacing", 0)
	sky.wind_parallax = skydata.get("WindParallax", 0)
	sky.wind_distance = skydata.get("WindDistance", 0)
	sky.clouds_parallax = skydata.get("CloudsParallax", 1.0)
	sky.shadow_opacity = skydata.get("ShadowOpacity", 0.7)
	sky.foliage_shadows = skydata.get("FoliageShadows", false)
	sky.no_per_face_layer_x_offset = skydata.get("NoPerFaceLayerXOffset", false)
	sky.layer_base_x_offset = skydata.get("LayerBaseXOffset", 0)

	active = sky
	return sky

