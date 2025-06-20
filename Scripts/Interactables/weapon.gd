class_name Weapon extends Node3D


@export var damage : float = 15.0
@export var automatic : bool = false

@export var positioning : Vector3
@export var animation : String = "rifle_1"

@onready var attack_cast : RayCast3D = $Model/Skeleton3D/Muzzle/AttackCast

@onready var model_root : Node3D = $Model
@onready var crosshair : Sprite3D = $Crosshair
@onready var animator : AnimationPlayer = $AnimationPlayer


func _ready():
	$EquipSound.play()

@rpc("any_peer", "call_local")
func shot():
	if animator.is_playing():
		return
	animator.play("shot_1")
	if attack_cast.get_collider() != null:
		if attack_cast.get_collider().has_method("take_damage"):
			attack_cast.get_collider().take_damage(damage)
		else:
			var collision_point = attack_cast.get_collision_point()
			var collision_normal = attack_cast.get_collision_normal()
			var instance = GameManager.get_object("bullethole")
			attack_cast.get_collider().add_child(instance)
			instance.global_position = collision_point
			instance.look_at(instance.global_transform.origin + collision_normal, Vector3.UP)
			if collision_normal != Vector3.UP and collision_normal != Vector3.DOWN:
				instance.rotate_object_local(Vector3.RIGHT,90)

func _physics_process(delta):
	if attack_cast.get_collider() != null:
		crosshair.show()
		crosshair.global_position = lerp(crosshair.global_position, attack_cast.get_collision_point(), 0.5)
	else:
		crosshair.hide()
