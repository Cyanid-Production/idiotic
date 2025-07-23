class_name ProfessionButton extends Button


var profession : Profession


func _ready():
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_hover)

func _on_pressed():
	GameManager.current_profession = profession
	get_parent().get_parent().get_node("DescLabel").text = profession.description_code
	get_tree().get_current_scene().get_node("Menu/Sounds/BestiarySound").play()
	get_parent().get_parent().show_equipment(profession)

func _on_hover():
	pass
