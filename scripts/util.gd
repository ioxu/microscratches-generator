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
