extends CharacterBody3D


var health : float = 100.0
var speed = 5.0
var jump_velocity = 4.5

var is_host : bool = false

var holding : bool = false
var current_weapon = null
var inventory_items : Array = []
var craft_allow : bool = false
var craft_points : int = 0
var craft_array
var current_trap
var current_trap_id

@onready var camera : Node3D = $Attachments/HeadAttachment/Camera
@onready var ui : Control = $Attachments/HeadAttachment/Camera/Camera3D/UI
@onready var interaction_cast : RayCast3D = $Attachments/HeadAttachment/Camera/InteractionCast
@onready var build_cast : RayCast3D = $Attachments/HeadAttachment/Camera/BuildCast
@onready var skeleton : Skeleton3D = $Body/Armature/Skeleton3D
@onready var attachment_node : Node3D = $Attachments
@onready var look_marker : Marker3D = $Attachments/LookMarker
@onready var spine_bone = skeleton.find_bone("mixamorig_Spine")
@onready var head_bone = skeleton.find_bone("mixamorig_Head")
@onready var jump_timer : Timer = $JumpTimer


func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	
	GameManager.players_array.append(self)
	
	inventory_items = GameManager.current_profession.start_items
	current_weapon = GameManager.current_profession.start_weapon
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.get_node("Camera3D").current = true
	ui.refresh_inventory()
	ui.show()
	
	GameManager.current_player = self

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		if look_marker.global_position.y < -6.0 and -event.relative.y < 0.0:
			return
		if look_marker.global_position.y > 6.0 and -event.relative.y > 0.0:
			return
		look_marker.global_position.y += (-event.relative.y * 0.01)
	
	if event.is_action_pressed("go_first"):
		equip_weapon.rpc()
	
	if event.is_action_pressed("go_second"):
		GameManager.start_game.rpc()

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("ui_accept"):
		jump_timer.start()
	
	if Input.is_action_just_pressed("LMB"):
		if build_cast.is_colliding() and ui.trap_menu.visible:
			craft_check(GameManager.get_item(current_trap_id))
			await get_tree().physics_frame
			if craft_allow:
				for i in GameManager.get_item(current_trap_id).craft_requirements:
					remove_from_inventory(i)
				place_building.rpc(current_trap_id, build_cast.get_collision_point())
		if get_node("Attachments").get_node("Weapon") != null and not get_node("Attachments").get_node("Weapon").automatic:
			get_node("Attachments").get_node("Weapon").shot.rpc()
	
	if Input.is_action_pressed("LMB"):
		if get_node("Attachments").get_node("Weapon") != null and get_node("Attachments").get_node("Weapon").automatic:
			get_node("Attachments").get_node("Weapon").shot.rpc()
	
	if not jump_timer.is_stopped() and is_on_floor():
		velocity.y = jump_velocity
	
	if Input.is_action_just_pressed("interact"):
		if interaction_cast.get_collider() != null and interaction_cast.get_collider().has_method("use"):
			interaction_cast.get_collider().use.rpc(name)
			hand_anim.rpc("interact_1")
	
	if interaction_cast.get_collider() != null:
		ui.interaction_icon.show()
	else:
		ui.interaction_icon.hide()
	
	var input_dir = Input.get_vector("go_left", "go_right", "go_forward", "go_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		$Body/Animators/LegsAnimator.play("walk_1")
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		$Body/Animators/LegsAnimator.stop()
	
	move_and_slide()

@rpc("any_peer", "call_local")
func equip_weapon():
	if current_weapon != null and current_weapon != "":
		if not holding:
			holding = true
			hand_anim("rifle_1")
			var weapon = GameManager.get_object(current_weapon)
			weapon.position = weapon.positioning
			attachment_node.add_child(weapon)
		else:
			holding = false
			hand_anim("rifle_1", true)
			attachment_node.get_node("Weapon").queue_free()

func add_to_inventory(item_id : String):
	inventory_items.append(item_id)
	ui.refresh_inventory()

func remove_from_inventory(item_id : String):
	inventory_items.erase(item_id)
	ui.refresh_inventory()

func craft_check(crf):
	craft_array = inventory_items.duplicate()
	craft_points = crf.craft_requirements.size()
	for i in crf.craft_requirements:
		if craft_array.has(i):
			craft_array.erase(i)
			craft_points -= 1
	if craft_points <= 0:
		craft_allow = true
	else:
		craft_allow = false

@rpc("any_peer", "call_local")
func place_building(bld:String,pos:Vector3):
	var new_building = GameManager.get_object(bld)
	new_building.global_position = pos
	add_sibling(new_building)
	GameManager.notificate(load("res://Sounds/Effects/trap_builded.wav"))

@rpc("any_peer", "call_local")
func play_step():
	if not is_on_floor():
		return
	$Sounds/StepSound.play()

@rpc("any_peer", "call_local")
func hand_anim(anim_name : String, backwards : bool = false):
	if not backwards:
		$Body/Animators/HandsAnimator.play(anim_name)
	else:
		$Body/Animators/HandsAnimator.play_backwards(anim_name)

func take_damage(dmg : float):
	health -= dmg
	if health <= 0:
		die.rpc()
	if not is_multiplayer_authority(): return
	ui.health_bar.material.set_shader_parameter("height", health / 100.0)
	ui.health_label.text = str(health)
	ui.damage_animator.play("blood"+str(randi_range(1,4)))

@rpc("any_peer", "call_local")
func die():
	GameManager.players_array.erase(self)
	var corpse = GameManager.get_object("corpse")
	corpse.global_position = global_position
	add_sibling(corpse)
	remove_from_group("Players")
	GameManager.new_target()
	if is_multiplayer_authority():
		get_tree().change_scene_to_file("res://Objects/DeathScreen.tscn")
	queue_free()
