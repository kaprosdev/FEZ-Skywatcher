extends VBoxContainer

func load_texture(tex_name: String, tex: Texture2D):
	$TextureName.text = tex_name
	$TextureDisplay.texture = tex
