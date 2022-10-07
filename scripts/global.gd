extends Node

var resolution : Vector2
var vector_direction : String


func report() -> void:
	print( "[global][report]" )
	print( "  resolution: %s"%resolution )
	print( "  vector direction: %s"%vector_direction )
	print( "  seed: %s"%Util.get_rng_seed() )


