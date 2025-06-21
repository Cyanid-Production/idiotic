extends Node3D


@export var stored_weapon : String = "hunterrifle"


@rpc("any_peer", "call_local")
func use(usr):
	GameManager.get_player(usr).current_weapon = stored_weapon
	queue_free()
