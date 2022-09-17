extends Node
# utility autoload

var RNG : RandomNumberGenerator

func _ready() -> void:
	RNG = RandomNumberGenerator.new()


# random -----------------------------------------------------------------------

func set_rng_seed( new_seed : int ) -> void:
	RNG.set_seed( new_seed )


func randi() -> int:
	RNG.randomize()
	return RNG.randi()


func randf_range( from : float, to: float) -> float:
	RNG.randomize()
	return RNG.randf_range( from , to)


# export -----------------------------------------------------------------------

func export_texture( tex : Texture, path : String ) -> void:
	var base = path.get_basename()
	# asset Texture
	var tex_data = tex.get_data()
	var image : Image = tex_data
	print("[util][export_texture] png: %s"%[base + ".png"])
	image.save_png( base + ".png" )
	
	var width = image.data["width"]
	var height = image.data["height"]
	var image_exr : Image = Image.new()
	image_exr.create( width, height, false, Image.FORMAT_RGBAH)
	image.lock()
	image_exr.lock()
	for x in range(width):
		for y in range(height):
			var c = image.get_pixel( x, y )
			# A R G B
			image_exr.set_pixel( x, y, Color( c.g, c.b, c.a, c.r ))
	image_exr.unlock()
	image.unlock()
	print("[util][export_texture] exr: %s"%[base + ".exr"])	
	image_exr.save_exr( base + ".exr", false )


