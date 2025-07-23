class_name InventoryItem extends TextureRect


@export var data : Item

var mouse_selected : bool = false


func _ready():
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture = data.texture
	tooltip_text = tr(data.name_code) + "\n\n" + tr(data.description_code)
	mouse_entered.connect(on_mouse)
	mouse_exited.connect(off_mouse)

func _input(event):
	if mouse_selected:
		if event.is_action_pressed("RMB") and data.consumable:
			var effect : String = data.use_effect.keys()[0]
			GameManager.current_player.add_effect(effect, data.use_effect.get(effect))
			GameManager.current_player.remove_from_inventory(data.id)
			queue_free()

func initialize(dta:Item):
	data = dta

func _get_drag_data(at_position):
	set_drag_preview(make_drag_preview(at_position))
	return self

func make_drag_preview(at_position):
	var t := TextureRect.new()
	t.texture = texture
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = size
	t.modulate.a = 0.5
	t.position = Vector2(-at_position)
	
	var c := Control.new()
	c.add_child(t)
	
	return c

func on_mouse():
	mouse_selected = true

func off_mouse():
	mouse_selected = false
