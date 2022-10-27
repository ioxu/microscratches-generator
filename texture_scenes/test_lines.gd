extends Node2D

var lines = []
var lines_colours = []

export var n_lines := 3000#10000

var idim = 1024
var mdim = idim * 3

var DRAW_ONCE = true
var DRAWN = false

func _ready() -> void:
	print("[test_lines] .size() %s"%lines.size())


func generate() -> void:
	print("[test_lines] generate")
	lines = []
	lines_colours = []
	for _l in range(n_lines):
		var startp = Vector2(_rdomain(), _rdomain())
		var endp = Vector2(_rdomain(), _rdomain())

		#var line = line_simple( startp, endp )
		var line = line_simple_simplex( startp, endp, _l)
		
		lines.append(line)
		if Global.vector_direction == "tangent":
			lines_colours.append( vcolours_simple(line, 0.0) )
		else:
			lines_colours.append( vcolours_simple(line) )
		
	DRAWN = false
	update()


func _rdomain() -> int:
	return Util.randi()%mdim - mdim * ( float(idim)/float(mdim) )


#func _process(delta: float) -> void:
#	update()


func _draw() -> void:
	if DRAW_ONCE and not DRAWN:
		#print("[test_lines] drawing once DRAW_ONCE %s DRAWN %s"%[DRAW_ONCE, DRAWN])
		for i in lines.size():
			draw_polyline_colors( lines[i], lines_colours[i], Util.randf_range(0.35, 2.0), false)
		DRAWN = true


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
	noise.seed = n_seed
	noise.octaves = 5
	noise.period = 20.0
	noise.persistence = 0.72
	
	var scale = 0.065
	var noise_amplitude = 35
	
	var points = []
	var n = 300

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
		c = Util.vec2_to_encoded_colour(c)
		c.b = r_b
		colours.append(c)
	return PoolColorArray( colours )
