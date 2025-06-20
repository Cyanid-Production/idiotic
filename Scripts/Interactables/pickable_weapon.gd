extends StaticBody3D


@export var stored_weapon : String


@rpc("any_peer", "call_local")
func use(usr):
	print(GameManager.get_player(usr))
	GameManager.get_player(usr).current_weapon = stored_weapon
	if multiplayer.is_server():
		await get_tree().physics_frame
	queue_free()
