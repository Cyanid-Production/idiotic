extends Node3D


@export var spawns_array : Array[Node3D]

@onready var spawn_timer : Timer = $Timer
@onready var alert_player : AudioStreamPlayer = $AlertSound

var waves_left : int = 0


@rpc("any_peer", "call_local")
func spawn_enemy():
	alert_player.pitch_scale = (1.5 - (waves_left/10.0))
	alert_player.play()
	waves_left += 1
	spawn_timer.wait_time += 5.0
	for i in 5:
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
