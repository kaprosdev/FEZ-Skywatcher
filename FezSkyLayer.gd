extends Object
class_name FezSkyLayer
## Data representation of a FEZ sky layer.
##
## Solely used to keep an internal data structure similar to the one used in FEZ.
## For sky layers as they are rendered in the Sky Preview, see (unimplemented)

## Name of the sky layer's texture.
var name: String
## Whether the sky layer should render in front of the rest of the game.
var in_front: bool
## The opacity of the sky layer.
var opacity: float
## How much (0-1) the sky layer should be tinted with the sky color.
var fog_tint: float

func to_dictionary() -> Dictionary:
	var self_dict: Dictionary = {
		"Name": name,
		"InFront": in_front,
		"Opacity": opacity,
		"FogTint": fog_tint
	}
	return self_dict
