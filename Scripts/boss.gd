extends StaticBody3D


var health : float = 3000.0

var attack_ray : PackedScene = preload("res://Objects/Projectiles/AttackRay.tscn")

@onready var ray_timer : Timer = $RayTimer
@onready var spawn_timer : Timer = $SpawnTimer


func _ready():
	$ProgressBar.max_value = health

func attack():
	for i in $Attacks.get_children():
		$Sounds/RaySound.play()
		ray_timer.start()
		i.add_child(attack_ray.instantiate())
		await ray_timer.timeout

func take_damage(dmg : float):
	health -= dmg
	$Sounds/DamageSound.play()
	if health <= 0:
		die.rpc()
	$ProgressBar.show()
	$ProgressBar.value = health

@rpc("any_peer", "call_local")
func die():
	GameManager.bestiary_objects.set("BOSS",true)
	GameManager.get_node("MusicPlayer").stop()
	get_tree().change_scene_to_file("res://Scenes/Outro.tscn")
	queue_free()

func _on_attack_timer_timeout():
	attack()

func _on_spawn_timer_timeout():
	for y in $Spawns.get_children():
		y.add_child(GameManager.get_object("zombie"))
		GameManager.new_target()
