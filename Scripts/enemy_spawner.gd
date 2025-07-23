extends Node3D


@export var spawns_array : Array[Node3D]

@onready var spawn_timer : Timer = $Timer
@onready var alert_player : AudioStreamPlayer = $AlertSound

var wave_passed : int = 0

@rpc("any_peer", "call_local")
func spawn_enemy():
	alert_player.pitch_scale = (1.5 - (wave_passed/10.0))
	wave_passed += 1
	GameManager.current_wave += 1
	GameManager.cast_update()
	spawn_timer.wait_time += 2.0
	alert_player.play()
	if GameManager.current_wave == 15:
		var new_boss = GameManager.get_object("boss")
		new_boss.global_position = Vector3(0.0,0.0,15.0)
		add_sibling(new_boss)
		get_parent().get_node("House/Room2/Objects/Altar").queue_free()
		get_parent().get_node("RifleSpawner").spawn.rpc()
		queue_free()
	for i in (1+(wave_passed*2)):
		var current_point = spawns_array.pick_random()
		var spawnpos = current_point.global_position
		var new_enemy = GameManager.get_object("zombie")
		new_enemy.global_position = spawnpos
		add_child(new_enemy, true)
	for y in round(0.2*wave_passed):
		var current_point = spawns_array.pick_random()
		var spawnpos = current_point.global_position
		var new_enemy = GameManager.get_object("shooter")
		new_enemy.global_position = spawnpos
		add_child(new_enemy, true)
	for y in round(0.1*wave_passed):
		var current_point = spawns_array.pick_random()
		var spawnpos = current_point.global_position
		var new_enemy = GameManager.get_object("dodger")
		new_enemy.global_position = spawnpos
		add_child(new_enemy, true)
	spawn_timer.start()
	GameManager.new_target()
	GameManager.wave_update()
	randomize()

func _on_timer_timeout():
	if GameManager.players_array[0] == GameManager.current_player and multiplayer.is_server():
		spawn_enemy.rpc()
