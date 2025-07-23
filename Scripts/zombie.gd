extends CharacterBody3D


var health : float = 30.0
var speed : float = 2.0

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var target_cast : RayCast3D = $TargetCast
@onready var body_animator : AnimationPlayer = $Body/Animator

var target
var attack_allow : bool = false
var direction


func _ready():
	GameManager.enemies_array.append(self)
	random_setup.rpc()

func _physics_process(delta):
	if not target == GameManager.players_array[0]:
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	direction = nav_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	
	if target == null:
		direction = global_position - global_position
	elif body_animator.current_animation != "attack_1" and transform.origin.distance_to(target.position) > 1.5:
		nav_agent.target_position = target.global_position
		look_at(Vector3(nav_agent.get_next_path_position().x,global_position.y,nav_agent.get_next_path_position().z))
		if not body_animator.is_playing():
			body_anim.rpc("walk_1")
	else:
		direction = Vector3(0.0,0.0,0.0)
	if target_cast.is_colliding() and not body_animator.current_animation == "attack_1":
		if target_cast.get_collider().is_in_group("Obstacles"):
			if target_cast.get_collider().locked:
				body_anim.rpc("attack_1")
			else:
				if is_on_floor():
					velocity.y = 8.0
		else:
			body_anim.rpc("attack_1")
	
	velocity = velocity.lerp(direction*speed,5*delta)
	move_and_slide()

func take_damage(dmg : float):
	health -= dmg
	var new_blood = GameManager.get_object("bloodsplatter")
	new_blood.global_position = global_position + Vector3(randf_range(-0.25,0.25),randf_range(0.75,1.25),randf_range(-0.25,0.25))
	add_sibling(new_blood)
	$Sounds/DamageSound.play()
	if health <= 0:
		die.rpc()

@rpc("any_peer", "call_local")
func random_setup():
	speed += randf_range(-0.5,0.5)

@rpc("any_peer", "call_local")
func die():
	GameManager.enemies_array.erase(self)
	var corpse = GameManager.get_object("corpse")
	corpse.global_position = global_position
	corpse.rot_coord = global_rotation
	add_sibling(corpse)
	var rand_var = randi_range(0,50)
	if rand_var == 25:
		death_drop.rpc()
	GameManager.bestiary_objects.set("ZOMBIE",true)
	queue_free()

@rpc("any_peer", "call_local")
func death_drop():
	var new_drop = GameManager.get_object("fixkit")
	new_drop.global_position = global_position
	add_sibling(new_drop)

@rpc("any_peer", "call_local")
func find_target(host_prevent:bool=true):
	target = GameManager.players_array[0]

@rpc("any_peer", "call_local")
func body_anim(anim_name : String):
	body_animator.play(anim_name)

func _on_animator_animation_finished(anim_name):
	match anim_name:
		"attack_1":
			if target_cast.is_colliding():
				if target_cast.get_collider().is_in_group("Obstacles") and not target_cast.get_collider().locked:
					pass
				else:
					if target_cast.get_collider().has_method("take_damage"):
						target_cast.get_collider().take_damage(20.0)
