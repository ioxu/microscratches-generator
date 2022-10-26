extends Node
# utility autoload

var RNG : RandomNumberGenerator
var rng_seed : int setget set_rng_seed, get_rng_seed

func _ready() -> void:
	RNG = RandomNumberGenerator.new()


# random -----------------------------------------------------------------------

func set_rng_seed( new_seed : int ) -> void:
	rng_seed = new_seed
	RNG.set_seed( new_seed )


func get_rng_seed() -> int:
	return rng_seed


func randf() -> float:
	return RNG.randf()


func randi() -> int:
	#RNG.randomize()
	return RNG.randi()


func randf_range( from : float, to: float) -> float:
	#RNG.randomize()
	return RNG.randf_range( from , to)


# vectors ----------------------------------------------------------------------

func vec2_to_encoded_colour( vec : Vector2 ) -> Color:
	vec *= Vector2(1.0, -1.0) 
	var ev = ( vec + Vector2(1.0, 1.0) ) / Vector2(2.0, 2.0)
	return Color(ev.x, ev.y, 0.0, 1.0)


# import -----------------------------------------------------------------------
func get_texture_scenes_list(paths : Array) -> String:
	var files = []
	var dir = Directory.new()

	for p in paths:
		dir.open(p)
		dir.list_dir_begin()
		while true:
			var file : String = dir.get_next()
			if file == "":
				break
			elif not file.begins_with("."):
				if file.ends_with(".tscn"):
					files.append(p +"/"+file)
		dir.list_dir_end()
	
	for f in files:
		pprint("    %s"%f)
	return files


# export -----------------------------------------------------------------------

# formats:
# Godot Spatial Material 
#	- "Flowmap" parameter - 90 CCW degrees rotated, encoded
#	- red and green channels define flow vector
#	- blue channel ignored
#	- anisotropy effect multiplied by alpha channel
# cycles
#	- use:
#		- Texture Interpolation: closest
#		- Principled Shader, Tangent node set to UVs plugged into Tangent port.
# Eevee (?)
# Arnold
# Unreal material
# OSL
# Appleseed
# LuxRender

func export_texture( tex : Texture, path : String ) -> void:
	var base = path.get_basename()
	# asset Texture
	var tex_data = tex.get_data()
	var image : Image = tex_data
	print("[util][export_texture] png: %s"%[base + ".png"])
# warning-ignore:return_value_discarded
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
# warning-ignore:return_value_discarded
	image_exr.save_exr( base + ".exr", false )


func pprint(thing) -> void:
	print("[util] %s"%str(thing))
