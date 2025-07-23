extends CharacterBody3D


var health : float = 90.0
var speed : float = 2.5

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var target_cast : RayCast3D = $Body/TargetCast
@onready var body_animator : AnimationPlayer = $Body/Animator
@onready var attack_animator : AnimationPlayer = $Body/AttackAnimator

var target
var attack_allow : bool = false


func _ready():
	GameManager.enemies_array.append(self)

func _physics_process(delta):
	if not target == GameManager.current_player:
		return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var direction = nav_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	
	if target == null:
		direction = global_position - global_position
	else:
		pass
	
	if target_cast.is_colliding() and target_cast.get_collider().has_method("take_damage") and not attack_animator.is_playing():
		direction = global_position - global_position
		look_at(Vector3(target.global_position.x,global_position.y,target.global_position.z))
		attack_anim.rpc("attack_1")
	else:
		nav_agent.target_position = target.global_position
		look_at(Vector3(nav_agent.get_next_path_position().x,global_position.y,nav_agent.get_next_path_position().z))
		if not body_animator.is_playing():
			body_anim.rpc("walk_1")
	
	velocity = velocity.lerp(direction*speed,5*delta)
	move_and_slide()

func take_damage(dmg : float):
	health -= dmg
	var new_blood = GameManager.get_object("bloodsplatter")
	new_blood.global_position = global_position + Vector3(randf_range(-0.25,0.25),randf_range(0.75,1.25),randf_range(-0.25,0.25))
	add_sibling(new_blood)
	if health <= 0:
		die.rpc()

@rpc("any_peer", "call_local")
func die():
	GameManager.enemies_array.erase(self)
	var corpse = GameManager.get_object("corpse")
	corpse.global_position = global_position
	corpse.rot_coord = global_rotation
	add_sibling(corpse)
	GameManager.bestiary_objects.set("SHOOTER",true)
	queue_free()

@rpc("any_peer", "call_local")
func find_target(host_prevent:bool=true):
	target = GameManager.players_array[0]

@rpc("any_peer", "call_local")
func body_anim(anim_name : String):
	body_animator.play(anim_name)

@rpc("any_peer", "call_local")
func attack_anim(anim_name : String):
	attack_animator.play(anim_name)

func _on_animator_animation_finished(anim_name):
	match anim_name:
		"attack_1":
			var new_proj = preload("res://Objects/Projectiles/SoulProjectile.tscn").instantiate()
			new_proj.global_position = global_position + Vector3(0.0,1.0,0.0)
			new_proj.target_vector = global_position.direction_to(target.global_position)
			#new_proj.velocity = -new_proj.transform.basis.z
			add_sibling(new_proj)
