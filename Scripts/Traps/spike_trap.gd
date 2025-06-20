extends StaticBody3D


@export var damage : float = 30.0

@onready var damage_area : Area3D = $DamageArea


func _ready():
	pass

func catch():
	for target in damage_area.get_overlapping_bodies():
		if target.has_method("take_damage"):
			target.take_damage(damage)

func _on_damage_area_body_entered(body):
	$AnimationPlayer.play("catch")
