extends Node2D

var lines = []
var lines_colours = []
var lines_widths = []

var _property_hash : int
var _prev_property_dict : Dictionary

var _dirty := false
signal dirty(state)
signal completed_generation

export var do_tiling := true
export var n_lines := 300  #10000
export var line_points := 300
export var local_seed := 1  

export var thickness_min := 0.1 
export var thickness_max := 3.5 


var idim = 1024
var mdim = idim * 3


onready var thread_o = preload("res://texture_scenes/test_lines_generator_thread.gd")


func _ready() -> void:
	print("[test_lines] .size() %s"%lines.size())

	_dirty = true
	_prev_property_dict = Util.get_exported_properties_dict( self )
	_property_hash = _prev_property_dict.hash()

	if Util.is_f6( self ):
		Global.resolution = get_viewport().get_size()

		# DEMO
		print("IS F6 in test_lines")
		self.generate()

		# parameters
		var pl = Util.get_exported_properties_list(self)
		for p in pl:
			print(p)


func _input(event: InputEvent) -> void:
	if Util.is_f6( self ):
		# DEMO
		if Input.is_key_pressed(KEY_H) and event.is_pressed() and not event.is_echo():
			self.visible = !self.visible
			print("toggle visiblity (\"h\") %s"%self.visible)
#				update()


func set(property: String, value) -> void:
	pprint("[_set] %s : %s (%s)"%[property, value, Util.PROPERTY_TYPE_STRINGS[typeof(value)]])
	# assume this property has been set through the Aniseed property editor
	# and mark the generator dirty if the value is now different
	if self.get( property ) != value:
		.set( property, value )
		self._dirty = true
		emit_signal("dirty", self._dirty)


func _on_set_dirty() -> void:
	# for connecting signals from nodes that would cause the texture_scene to become dirty.
	# e.g. when the ui changes something to do with image settings, like resolution.
	self._dirty = true
	emit_signal("dirty", self._dirty)


func is_dirty() -> bool:
	return self._dirty


func generate() -> void:
	self.lines.clear()
	self.lines_colours.clear()
	self.lines_widths.clear()
	
	if self._dirty:
		var r = thread_o.new(
			{"n_lines": n_lines,
			"idim": int(Global.resolution.x),
			"do_tiling": self.do_tiling,
			"thickness_max": self.thickness_max,
			"thickness_min": self.thickness_min,
			"n_points": self.line_points,
			"vector_direction": Global.vector_direction,
			"local_seed": self.local_seed,
			})
		self.add_child( r )
		r.connect( "work_completed", self, "_on_work_completed" )
		r.start()
		print("thread started: %s"%r)


func _on_work_completed( thread_node : Node, data : Array ) -> void:
	self.lines = data[0].duplicate()
	self.lines_colours = data[1].duplicate()
	self.lines_widths = data[2].duplicate()
	thread_node.queue_free()
	update()
	self._dirty = false
	emit_signal("dirty", self._dirty)
	emit_signal("completed_generation")


func _rdomain() -> int:
	return Util.randi()%mdim - mdim * ( float(idim)/float(mdim) )


func _draw() -> void:
	for i in lines.size():
		draw_polyline_colors( lines[i], lines_colours[i], lines_widths[i], false)


#-------------------------------------------------------------------------------
# line generators

# two-point line
func line_simple( startp:Vector2, endp:Vector2 ) -> PoolVector2Array:
	return PoolVector2Array( [ startp, endp ] )


func line_simple_simplex( startp:Vector2,
	endp:Vector2, n_seed: int = 1) -> PoolVector2Array:
	var noise = OpenSimplexNoise.new()

	# Configure
	#noise.seed = randi()
	noise.seed = n_seed + self.local_seed
	noise.octaves = 5
	noise.period = 20.0
	noise.persistence = 0.72
	
	var scale = 0.065
	var noise_amplitude = 35
	
	var points = []
	var n = line_points

	for i in range(n):
		var r = float(i)/(n-1)
		var p = lerp(startp, endp, r)
		#print("r %s p %s"%[r,p])
		var nn = Vector2( noise.get_noise_2dv( p * scale ) , noise.get_noise_2dv( p * scale + Vector2(-316, 37.5) ) )
		#print("nn %s"%nn)
		p += nn * noise_amplitude
		points.append( p )

	return PoolVector2Array( points )

#-------------------------------------------------------------------------------
# colour-at--vertices generators

# loops points,
# gen colour by delta from this point to next point
# doubles up last point
# puts a random value for the whole curve in blue channel
# by default, returns bitangent colours - argument 'rotated' (degrees) can be set to 0 to supply tangent colours
func vcolours_simple( points : PoolVector2Array, rotated : float = 90 ) -> PoolColorArray :
	var _size = points.size()
	var colours = []
	var r_b = Util.randf()
	for i in range(_size):
		var next_i = i+1
		if next_i > _size-1:
			next_i = i
		var c = (points[i] - points[next_i]).normalized()
		c = c.rotated( deg2rad(rotated) )
		#c = lerp( c, Vector2.UP, 0.85 ).normalized()
		c = Util.vec2_to_encoded_colour(c)
		c.b = r_b
		colours.append(c)
	return PoolColorArray( colours )



func pprint(thing) -> void:
	print("[test_lines] %s"%str(thing))
