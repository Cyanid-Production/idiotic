extends CharacterBody3D


var rot_coord : Vector3


@rpc("any_peer", "call_local")
func _ready():
	global_rotation = rot_coord + Vector3(0,160,0)
	$SimulationTimer.start()
	$AudioStreamPlayer.play()
	$Armature/AnimationPlayer.play("death_"+str(randi_range(1,3)))


func _on_simulation_timer_timeout():
	$AnimationPlayer.play("bleeding")

func _on_visible_on_screen_notifier_3d_screen_exited():
	if $DespawnTimer.is_stopped():
		queue_free()
