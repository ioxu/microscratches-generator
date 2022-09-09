extends Node2D

var lines = []
var lines_colours = []

var n_lines = 5000

var idim = 1024
var mdim = idim * 3


func _ready() -> void:
	print("[lines] generate")
	for l in range(n_lines):
		
		
		
		var la = []
		var startp = Vector2( _rdomain(), _rdomain()  )
		var endp = Vector2( _rdomain(), _rdomain()  )

		la.append(startp)
		la.append(endp)

		var lc = []
		lc.append(Color(randf(), randf(), randf()))
		lc.append(Color(randf(), randf(), randf()))

		lines.append(PoolVector2Array( la ))
		lines_colours.append( PoolColorArray( lc ) )


func _rdomain() -> int:
	return randi()%mdim - (mdim*0.3333)

func _draw() -> void:
	for i in lines.size():
		draw_polyline_colors( lines[i], lines_colours[i], 0.5, false)
