class_name Projectile extends Area3D


@export var damage : float = 25.0
@export var speed : float = 30.0

var velocity = Vector3.ZERO
var target_vector : Vector3


func _physics_process(delta):
	velocity += target_vector * speed * delta
	#look_at(global_position + velocity.normalized(), Vector3.UP)
	global_position += velocity * delta

func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()
