extends Control


var inventory_size = 36

@onready var root_player = $"../../../../.."

@onready var inventory : GridContainer = $InventioryGrid
@onready var stat_menu : Control = $StatsControl
@onready var trap_menu : Control = $TrapMenu

@onready var damage_animator : AnimationPlayer = $DamageOverlay/AnimationPlayer

@onready var interaction_icon : TextureRect = $InteractionIcon
@onready var health_bar : ColorRect = $StatsControl/HealthBar
@onready var health_label : Label = $StatsControl/HealthBar/Label

var click_scroll_sound = preload("res://Sounds/Effects/click_scroll.wav")


func _ready():
	if GameManager.current_profession.id == "load":
		inventory_size += 12
	for i in inventory_size:
		var slot := InventorySlot.new()
		slot.add_to_grid(Item.Type.ITEM, Vector2(120,120))
		inventory.add_child(slot)
	
	refresh_inventory()

func flash():
	$Flash/AnimationPlayer.play("flash")
	GameManager.notificate(load("res://Sounds/Player/heal1.wav"))

func refresh_inventory():
	for f in inventory.get_children():
		for j in f.get_children():
			j.queue_free()
	for i in root_player.inventory_items.size():
		var item := InventoryItem.new()
		item.initialize(GameManager.get_item(root_player.inventory_items[i]))
		inventory.get_child(i).add_child(item)

func add_item(itm:Item):
	var empty_slot
	for i in inventory.get_children():
		if not i.get_child_count() > 0:
			empty_slot = i
			var new_item = InventoryItem.new()
			new_item.initialize(itm)
			empty_slot.add_child(new_item)
			return

func set_hint(txt:String):
	$HintLabel.text = txt
	$HintLabel.show()

func hide_hint():
	$HintLabel.hide()

func _physics_process(_delta):
	if Input.is_action_just_pressed("inventory"):
		GameManager.notificate(load("res://Sounds/Effects/click_interface.wav"))
		if inventory.visible:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			inventory.hide()
		elif not root_player.holding:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			inventory.show()
	if Input.is_action_just_pressed("traps"):
		if trap_menu.visible:
			trap_menu.hide()
		elif not root_player.holding:
			trap_menu.show()
	if Input.is_action_just_pressed("ESC"):
		GameManager.notificate(load("res://Sounds/Effects/click_interface.wav"))
		if $ExitMenu.visible:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		$ExitMenu.visible = !$ExitMenu.visible

func _on_menu_button_pressed():
	get_tree().get_current_scene().get_node("Menu").enable()
	get_tree().get_current_scene().get_node("Map").queue_free()

func _on_quit_button_pressed():
	get_tree().quit()
