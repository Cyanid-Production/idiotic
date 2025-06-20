extends Node3D


@onready var model = $Model

@export var item_to_pick : Item


func _ready():
	model.mesh = item_to_pick.model

@rpc("any_peer", "call_local")
func use(usr):
	usr.add_to_inventory(item_to_pick.id)
	queue_free()
