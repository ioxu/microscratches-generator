extends Node
var thread

var texture : Texture
var path : String

signal texture_export_progressed(progress, meta)


func _init( tex : Texture, pth : String) -> void:
	texture = tex
	path = pth
	pprint(" _init() (%s, %s)"%[ texture, path ])
	thread = Thread.new()


func start() -> void:
	pprint(" start()")
	thread.start(self, "_do_export_texture", [self.texture, self.path] )


func _do_export_texture(conf : Array) -> void:
	pprint(" _do_export_texture()")
# warning-ignore:shadowed_variable
	var ttexture = conf[0]
	pprint("texture : %s"%ttexture)
# warning-ignore:shadowed_variable
	var ppath = conf[1]
	pprint("path : %s"%ppath)
	
	var base = ppath.get_basename()
	# asset Texture
	emit_signal("texture_export_progressed", 0.0, "get texture data" )
	var tex_data = ttexture.get_data()
	var image : Image = tex_data
	pprint("[export_texture] png: %s"%[base + ".png"])
	emit_signal("texture_export_progressed", 0.0, "convert to RGBA8" )
	image.convert(Image.FORMAT_RGBA8)
	emit_signal("texture_export_progressed", 0.0, "save PNG" )
# warning-ignore:return_value_discarded
	image.save_png( base + ".png" )
	
	var width = image.data["width"]
	var height = image.data["height"]
	emit_signal("texture_export_progressed", 0.0, "new image" )
	var image_exr : Image = Image.new()
	emit_signal("texture_export_progressed", 0.0, "create RGBAH" )
	image_exr.create( width, height, false, Image.FORMAT_RGBAH)
	image.lock()
	image_exr.lock()
	for x in range(width):
		emit_signal("texture_export_progressed", (float(x)/width)*100, "converting pixels" )
		for y in range(height):
			var c = image.get_pixel( x, y )
			# A R G B
			image_exr.set_pixel( x, y, Color( c.g, c.b, c.a, c.r ))
	image_exr.unlock()
	image.unlock()
	pprint("[export_texture] exr: %s"%[base + ".exr"])
	emit_signal("texture_export_progressed", 100.0, "save EXR" )
# warning-ignore:return_value_discarded
	image_exr.save_exr( base + ".exr", false )
	
	emit_signal("texture_export_progressed", 100.0, "DONE")


func _exit_tree() -> void:
	pprint(" _exit_tree()")
	thread.wait_to_finish()


func pprint(thing) -> void:
	print("[texture export thread] %s"%str(thing))
