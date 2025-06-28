extends Control


var professions_list : Array[Profession] = [
	load("res://Resources/Professions/Blacksmith.tres"),
	load("res://Resources/Professions/Carpenter.tres"),
	load("res://Resources/Professions/Hunter.tres"),
	load("res://Resources/Professions/Soldier.tres")
]

@onready var prof_container : VBoxContainer = $ProfessionContainer


func _ready():
	for i in professions_list:
		var new_button = ProfessionButton.new()
		new_button.text = tr(i.namecode)
		new_button.profession = i
		if i.namecode == "HUNTER_NAME" or i.namecode == "SOLDIER_NAME":
			new_button.disabled = true
		prof_container.add_child(new_button)


func _on_tab_container_tab_selected(tab):
	$"../../../Sounds/CustomizeSound".play()
