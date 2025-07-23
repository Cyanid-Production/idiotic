extends Node3D


var weapon : PackedScene = preload("res://Objects/Interactables/PickableWeapon.tscn")


@rpc("any_peer", "call_local")
func spawn():
	for i in get_children():
		i.add_child(weapon.instantiate())
