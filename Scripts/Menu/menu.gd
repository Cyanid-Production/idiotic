extends CanvasLayer


@onready var adress_enter : LineEdit = $Control/AdressEnter

const PORT = 6969
var enet_peer = ENetMultiplayerPeer.new()

func disable():
	hide()
	$SubViewportContainer/SubViewport/Objects.hide()

func enable():
	show()
	$SubViewportContainer/SubViewport/Objects.show()


func _on_host_button_pressed():
	disable()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	
	add_player(multiplayer.get_unique_id())

func _on_join_button_pressed():
	disable()
	
	enet_peer.create_client(adress_enter.text, PORT)
	multiplayer.multiplayer_peer = enet_peer
	
	add_player(multiplayer.get_unique_id(), false)

func _on_quit_button_pressed():
	get_tree().quit()

func add_player(peer_id : int, is_host : bool = true):
	get_tree().get_current_scene().add_child(preload("res://Scenes/Map1.tscn").instantiate(), true)
	$"../MultiplayerSpawner".spawn_path = "../Map"
	var new_player = GameManager.get_object("player")
	new_player.name = str(peer_id)
	new_player.global_position = Vector3(0,1,0)
	get_tree().get_current_scene().get_node("Map").add_child(new_player, true)
	GameManager.on_host = is_host
	await get_tree().physics_frame
