extends Area3D


func _on_body_entered(body):
	if body.get_node_or_null("Attachments/HandAttachment/MeleeWeapon") != null:
		body.get_node("Attachments/HandAttachment/MeleeWeapon").durability += 15.0
		body.ui.flash()
		queue_free()
