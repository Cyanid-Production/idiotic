extends Node3D


@export var spawns_array : Array[Node3D]

@onready var spawn_timer : Timer = $Timer


@rpc("any_peer", "call_local")
func spawn_enemy():
	var current_point = spawns_array.pick_random()
	var spawnpos = current_point.global_position
	var new_enemy = GameManager.get_object("zombie")
	new_enemy.global_position = spawnpos
	add_child(new_enemy, true)
	spawn_timer.start()
	GameManager.new_target()

func _on_timer_timeout():
	if GameManager.players_array[0] == GameManager.current_player:
		spawn_enemy.rpc()
