extends CanvasLayer


@onready var adress_enter : LineEdit = $Control/AdressEnter

const PORT = 6969
var enet_peer = ENetMultiplayerPeer.new()

func disable():
	hide()
	$SubViewportContainer/SubViewport/Objects.hide()
	$Control/TabContainer/ProfessionMenu/SubViewportContainer/SubViewport/Objects.hide()

func enable():
	show()
	$SubViewportContainer/SubViewport/Objects.show()
	$Control/TabContainer/ProfessionMenu/SubViewportContainer/SubViewport/Objects.show()

func ready_check():
	if GameManager.current_profession != null:
		return true
	else:
		return false

func _on_host_button_pressed():
	if not ready_check(): return
	
	disable()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	
	add_player(multiplayer.get_unique_id())

func _on_join_button_pressed():
	if not ready_check(): return
	
	disable()
	
	enet_peer.create_client(adress_enter.text, PORT)
	multiplayer.multiplayer_peer = enet_peer
	
	add_player(multiplayer.get_unique_id(), false)

func _on_character_button_pressed():
	$Sounds/CustomizeSound.play()
	$Control/TabContainer.visible = !$Control/TabContainer.visible

func _on_settings_button_pressed():
	$Sounds/CustomizeSound.play()
	$Control/SettingsContainer.visible = !$Control/SettingsContainer.visible

func _on_quit_button_pressed():
	get_tree().quit()

func add_player(peer_id : int, is_host : bool = true):
	get_tree().get_current_scene().get_node("Map").show()
	var new_player = GameManager.get_object("player")
	new_player.name = str(peer_id)
	new_player.global_position = Vector3(0,1,0)
	get_tree().get_current_scene().get_node("Map").add_child(new_player, true)
	GameManager.on_host = is_host
	if is_multiplayer_authority():
		GameManager.redraw_map()
	await get_tree().physics_frame
