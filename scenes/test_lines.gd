extends Node2D

var lines = []
var lines_colours = []

var n_lines = 200

var idim = 1024
var mdim = idim * 3

var DRAW_ONCE = true
var DRAWN = false

func _ready() -> void:
	print("[lines] generate")
	for l in range(n_lines):

#		var la = []
#		var startp = Vector2( _rdomain(), _rdomain()  )
#		var endp = Vector2( _rdomain(), _rdomain()  )
#
#		la.append(startp)
#		la.append(endp)
#
#		var lc = []
#
#		var cc = (startp - endp).normalized()
#		cc = vec2_to_encoded_colour(cc)
#		lc.append(cc)
#		lc.append(cc)
#
#		lines.append(PoolVector2Array( la ))
#		lines_colours.append( PoolColorArray( lc ) )
		var line = line_simple( Vector2(_rdomain(), _rdomain()), Vector2(_rdomain(), _rdomain()) )
		lines.append(line)
		lines_colours.append( vcolours_simple(line) )
		


func _rdomain() -> int:
	return randi()%mdim - (mdim*0.3333)


func vec2_to_encoded_colour( vec : Vector2 ) -> Color:
	vec *= Vector2(1.0, -1.0) 
	var ev = ( vec + Vector2(1.0, 1.0) ) / Vector2(2.0, 2.0)
	return Color(ev.x, ev.y, 0.0, 1.0)


#func _process(delta: float) -> void:
#	update()


func _draw() -> void:
	#print(self.get_path(), "_draw()")
	if DRAW_ONCE and not DRAWN:
#		print("[test_lines] drawing once DRAW_ONCE %s DRAWN %s"%[DRAW_ONCE, DRAWN])
		for i in lines.size():
			draw_polyline_colors( lines[i], lines_colours[i], 2.0, false)
		DRAWN = true


#-------------------------------------------------------------------------------
# line generators

# two-point line
func line_simple( startp:Vector2, endp:Vector2 ) -> PoolVector2Array:
	return PoolVector2Array( [ startp, endp ] )

#-------------------------------------------------------------------------------
# colour-at--vertices generators

# loops points,
# gen colour by delta from this point to next point
# doubles up last point
func vcolours_simple( points : PoolVector2Array ) -> PoolColorArray :
	var _size = points.size()
	var colours = []
	for i in range(_size):
		print("i %s"%i)
		var next_i = i+1
		if next_i > _size-1:
			next_i = i
		var c = (points[i] - points[next_i]).normalized()
		c = vec2_to_encoded_colour(c)
		colours.append(c)
	return PoolColorArray( colours )
