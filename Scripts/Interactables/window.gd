extends Area3D


var health : float = 0.0
var locked : bool = false

@export var planks : Array[StaticBody3D]


func change_health(hlt:float):
	health += hlt
	if health <= 0.0:
		locked = false
		health = 0.0
		$"../Collisions/CSGBox3D".use_collision = false
	else:
		locked = true
		$"../Collisions/CSGBox3D".use_collision = true
	for i in planks:
		i.hide()
	var planks_amount = round(health/20.0)
	if planks_amount >= 1:
		planks[0].show()
	if planks_amount >= 2:
		planks[1].show()
	if planks_amount >= 3:
		planks[2].show()
	if planks_amount >= 4:
		planks[3].show()
	if planks_amount >= 5:
		planks[4].show()

@rpc("any_peer", "call_local")
func use(usr):
	if GameManager.get_player(usr).inventory_items.has(GameManager.get_item("planks")) and health <= 80.0:
		GameManager.get_player(usr).remove_from_inventory("planks")
		change_health(20.0)

func take_damage(dmg:float):
	change_health(-dmg/10.0)
