extends Control


var professions_list : Array[Profession] = [
	load("res://Resources/Professions/Unemployed.tres"),
	load("res://Resources/Professions/Blacksmith.tres"),
	load("res://Resources/Professions/Carpenter.tres"),
	load("res://Resources/Professions/Hunter.tres"),
	load("res://Resources/Professions/Loader.tres"),
	load("res://Resources/Professions/Soldier.tres"),
	load("res://Resources/Professions/Samurai.tres")
]

@onready var prof_container : VBoxContainer = $ProfessionContainer
@onready var character : Skeleton3D = $SubViewportContainer/SubViewport/Objects/Body/Armature/Skeleton3D


func _ready():
	for i in professions_list:
		var new_button = ProfessionButton.new()
		new_button.text = i.namecode
		new_button.profession = i
		prof_container.add_child(new_button)

func show_equipment(prf:Profession):
	for i in character.get_children():
		if i.name != "BodyMesh":
			i.hide()
	var equip = character.get_node_or_null(prf.id)
	if equip != null:
		equip.show()

func _on_tab_container_tab_selected(_tab):
	$"../../../Sounds/CustomizeSound".play()
