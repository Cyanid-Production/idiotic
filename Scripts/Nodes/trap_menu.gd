extends Control


@onready var trap_thumbnail : TextureRect = $MarginContainer/Panel/TrapTexture
@onready var trap_name : Label = $MarginContainer/Panel/NameLabel
@onready var trap_desc : Label = $MarginContainer/Panel/DescriptionLabel

var traps_array : Array[Trap] = [
	preload("res://Resources/Traps/SpikeTrap1.tres"),
	preload("res://Resources/Traps/SpikeTrap2.tres"),
	preload("res://Resources/Traps/SpikeTrap3.tres")
]
var current_trap_id : int


func _input(event):
	if event.is_action_pressed("zoom_in"):
		if current_trap_id >= traps_array.size()-1:
			current_trap_id = 0
		else:
			current_trap_id += 1
		set_current_trap(current_trap_id)
		GameManager.notificate(get_parent().click_scroll_sound)

func _ready():
	set_current_trap(0)

func set_current_trap(trp_id:int):
	current_trap_id = trp_id
	var trp = traps_array[trp_id]
	trap_thumbnail.texture = trp.thumnbail
	trap_name.text = tr(trp.name_tag)
	trap_desc.text = tr(trp.description_tag)
	await get_tree().physics_frame
	get_parent().root_player.current_trap = trp.trap_scene
	get_parent().root_player.current_trap_id = trp.trap_id
