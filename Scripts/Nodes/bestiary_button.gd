class_name BestiaryButton extends Button


var id : String


func _ready():
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_hover)

func _on_pressed():
	get_parent().get_parent().get_node("NameLabel").text = (id + "_NAME")
	get_parent().get_parent().get_node("DescLabel").text = (id + "_DESC")
	get_parent().get_parent().get_node("Background").texture = load("res://Textures/Menu/Bestiary/"+id+".png")
	get_tree().get_current_scene().get_node("Menu/Sounds/BestiarySound").play()

func _on_hover():
	pass
