extends Node
var thread : Thread
var debug := true
var data : Array
var configuration : Dictionary

signal work_completed(thread_o, data)

var RNG = RandomNumberGenerator.new()


func _init( conf: Dictionary ) -> void:
	pprint("_init")
	configuration = conf
	pprint("configuration %s"%self.configuration)
	thread = Thread.new()
	RNG.set_seed( 1 ) # TODO
	data = []


func start() -> void:
	pprint("start")
	thread.start(self, "_do_generate", self.configuration)


func _do_generate(conf:Dictionary) -> Array:
	pprint("_do_generate start .. ")



	var idim = conf["idim"]
	var mdim = int(idim * 3)

	var lines = []
	var lines_colours = []
	var lines_widths = []
	for _l in range(conf["n_lines"]):
		var startp = Vector2(_rdomain(idim, mdim), _rdomain(idim, mdim))
		var endp = Vector2(_rdomain(idim, mdim), _rdomain(idim, mdim))
		var line = line_simple_simplex( startp, endp, _l + conf["local_seed"], conf["n_points"])
		lines.append(line)
		if conf["do_tiling"]:
			lines.append( Util.copyOffset_PoolVector2Array( line, Vector2( idim , 0.0 )  ) )
			lines.append( Util.copyOffset_PoolVector2Array( line, Vector2( -idim , 0.0 )  ) )
			lines.append( Util.copyOffset_PoolVector2Array( line, Vector2( idim , idim )  ) )
			lines.append( Util.copyOffset_PoolVector2Array( line, Vector2( -idim , idim )  ) )
			lines.append( Util.copyOffset_PoolVector2Array( line, Vector2( idim , -idim )  ) )
			lines.append( Util.copyOffset_PoolVector2Array( line, Vector2( -idim , -idim )  ) )
			lines.append( Util.copyOffset_PoolVector2Array( line, Vector2( 0.0 , idim )  ) )
			lines.append( Util.copyOffset_PoolVector2Array( line, Vector2( 0.0 , -idim )  ) )

#		if _l%500 == 0: print("############ %s %s (%s)"%[self, _l, lines.size()])
	
		var vc : PoolColorArray
		if conf["vector_direction"] == "tangent":
			vc = vcolours_simple(line, 0.0)
		else:
			vc = vcolours_simple(line)
		lines_colours.append( vc )
		if conf["do_tiling"]:
			lines_colours.append( vc )
			lines_colours.append( vc )
			lines_colours.append( vc )
			lines_colours.append( vc )
			lines_colours.append( vc )
			lines_colours.append( vc )
			lines_colours.append( vc )
			lines_colours.append( vc )
		
		var vw = Util.randf_range(conf["thickness_max"], conf["thickness_min"])
		lines_widths.append( vw )
		if conf["do_tiling"]:
			lines_widths.append( vw )
			lines_widths.append( vw )
			lines_widths.append( vw )
			lines_widths.append( vw )
			lines_widths.append( vw )
			lines_widths.append( vw )
			lines_widths.append( vw )
			lines_widths.append( vw )

	pprint(".. _do_generate end")
	call_deferred( "end" )
	return [lines, lines_colours, lines_widths]


func end():
	var result = thread.wait_to_finish()
	pprint("end")
	emit_signal( "work_completed", self, result  )
	#self.queue_free()


func _exit_tree() -> void:
	pprint("%s _exit_tree"%self.thread)


func pprint(thing) -> void:
	if self.debug:
		print("[ --- test_lines_generator_thread] %s"%str(thing))


func _rdomain(idim, mdim) -> int:
	return Util.randi()%mdim - mdim * ( float(idim)/float(mdim) )


func line_simple_simplex( startp:Vector2,
							endp:Vector2,
							n_seed: int = 1,
							n_points : int =200) -> PoolVector2Array:

	var noise = OpenSimplexNoise.new()
	# Configure
	noise.seed = n_seed
	noise.octaves = 5
	noise.period = 20.0
	noise.persistence = 0.72
	
	var scale = 0.065
	var noise_amplitude = 35
	
	var points = []
	var n = n_points
	for i in range(n):
		var r = float(i)/(n-1)
		var p = lerp(startp, endp, r)
		var nn = Vector2( noise.get_noise_2dv( p * scale ) , noise.get_noise_2dv( p * scale + Vector2(-316, 37.5) ) )
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
	var r_b = RNG.randf()
	for i in range(_size):
		var next_i = i+1
		if next_i > _size-1:
			next_i = i
		var c = (points[i] - points[next_i]).normalized()
		c = c.rotated( deg2rad(rotated) )
		c = Util.vec2_to_encoded_colour(c)
		c.b = r_b
		colours.append(c)
	return PoolColorArray( colours )


func vec2_to_encoded_colour( vec : Vector2 ) -> Color:
	vec *= Vector2(1.0, -1.0) 
	var ev = ( vec + Vector2(1.0, 1.0) ) / Vector2(2.0, 2.0)
	return Color(ev.x, ev.y, 0.0, 1.0)
