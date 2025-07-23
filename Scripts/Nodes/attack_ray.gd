extends Area3D


func _on_timer_timeout():
	queue_free()

func _on_body_entered(body):
	body.take_damage(25.0)
