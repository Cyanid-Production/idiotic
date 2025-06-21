class_name ProfessionButton extends Button


var profession : Profession


func _ready():
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_hover)

func _on_pressed():
	GameManager.current_profession = profession

func _on_hover():
	get_parent().get_parent().get_node("DescLabel").text = tr(profession.description_code)
