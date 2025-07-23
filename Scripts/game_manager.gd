extends Node


signal on_game_started

var players_amount : int = 0

var current_player : CharacterBody3D
var players_array : Array
var enemies_array : Array
var on_host : bool

var current_profession : Profession

var current_wave : int = 0
var wave_enemy_amount = 2
var wave_countdown : int = 30

var grain_display : bool = true
var grass_display : bool = true

var altar_cast : Array[String] = [
	"air"
]

var menu : Node
var map : Node

@onready var wave_timer : Timer = $WaveTimer

var preloaded_objects = {
	### CHARACTERS ###
	"player" : preload("res://Objects/Player.tscn"),
	"zombie" : preload("res://Objects/Zombie.tscn"),
	"shooter" : preload("res://Objects/Shooter.tscn"),
	"dodger" : preload("res://Objects/Dodger.tscn"),
	"corpse" : preload("res://Objects/Corpse.tscn"),
	"boss" : preload("res://Objects/Boss.tscn"),
	### TRAPS ###
	"spiketrap1" : preload("res://Objects/Traps/SpikeTrap1.tscn"),
	"spiketrap2" : preload("res://Objects/Traps/SpikeTrap2.tscn"),
	"spiketrap3" : preload("res://Objects/Traps/SpikeTrap3.tscn"),
	"defensetrap1" : preload("res://Objects/Traps/DefenseTrap1.tscn"),
	### WEAPONS ###
	"hunterrifle" : preload("res://Objects/Weapons/SKSrifle.tscn"),
	"ak47" : preload("res://Objects/Weapons/AK47.tscn"),
	### MELEE ###
	"katana" : preload("res://Objects/Weapons/Katana.tscn"),
	### OTHER ###
	"bullethole" : preload("res://Objects/Decor/BulletHole.tscn"),
	"bloodsplatter" : preload("res://Objects/Effects/BloodSplatter.tscn"),
	"fixkit" : preload("res://Objects/Interactables/FixKit.tscn")
}

var player_items : Dictionary = {
	### MATERIALS ###
	"cloth" : preload("res://Resources/Items/Cloth.tres"),
	"petrol" : preload("res://Resources/Items/Petrol.tres"),
	"planks" : preload("res://Resources/Items/Planks.tres"),
	"iron" : preload("res://Resources/Items/Iron.tres"),
	"sake" : preload("res://Resources/Items/Sake.tres"),
	"medkit" : preload("res://Resources/Items/Medkit.tres"),
	### CRAFTABLES ###
	"spiketrap1" : preload("res://Resources/Traps/SpikeTrap1.tres"),
	"spiketrap2" : preload("res://Resources/Traps/SpikeTrap2.tres"),
	"spiketrap3" : preload("res://Resources/Traps/SpikeTrap3.tres"),
	"defensetrap1" : preload("res://Resources/Traps/DefenseTrap1.tres")
}

var bestiary_objects : Dictionary = {
	### CHARACTERS ###
	"PLAYER" : true,
	"ZOMBIE" : false,
	"SHOOTER" : false,
	"DODGER" : false,
	"BOSS" : false
}

func _ready():
	load_data()
	wave_timer.wait_time = wave_countdown
	
	await get_tree().physics_frame

func get_object(key_to:String):
	return preloaded_objects.get(key_to).instantiate()

func get_player(player_id):
	return get_tree().get_current_scene().get_node("Map/"+player_id)

func get_item(key_to:String):
	return player_items.get(key_to)

@rpc("any_peer", "call_local")
func start_game():
	on_game_started.emit()
	new_target()
	get_parent().get_node("Test/Map/EnemySpawner/Timer").start()
	set_soundtrack(load("res://Music/light-slaughter.ogg"))
	get_tree().get_current_scene().get_node("Map/House/Room2/Objects/Altar/RechargeTimer").start()

func game_reset():
	print("RESET")
	
	players_amount = 0
	
	current_wave = 0
	wave_enemy_amount = 2
	wave_countdown = 30
	
	altar_cast = ["air"]
	
	current_player = null
	players_array.clear()
	enemies_array.clear()

func set_soundtrack(snd:AudioStream,vol:float=0.0,ptc:float=1.0):
	$MusicPlayer.stream = snd
	$MusicPlayer.volume_db = vol
	$MusicPlayer.pitch_scale = ptc
	$MusicPlayer.play()

@rpc("any_peer", "call_local")
func instasound(snd:AudioStream,caller:Node=self,vol:float=0.0,ptc:float=1.0):
	var new_sound := AudioStreamPlayer.new()
	new_sound.stream = snd
	new_sound.volume_db = vol
	new_sound.pitch_scale = ptc
	caller.add_sibling(new_sound)
	new_sound.finished.connect(new_sound.queue_free)
	new_sound.play()

@rpc("any_peer", "call_local")
func instasound3D(caller:Node3D,snd:AudioStream,vol:float=0.0,ptc:float=1.0):
	var new_sound := AudioStreamPlayer3D.new()
	new_sound.stream = snd
	new_sound.volume_db = vol
	new_sound.pitch_scale = ptc
	new_sound.global_transform = caller.global_transform
	caller.add_sibling(new_sound)
	new_sound.finished.connect(new_sound.queue_free)
	new_sound.play()

func notificate(snd:AudioStream):
	$NotificationPlayer.stream = snd
	$NotificationPlayer.play()

func wave_update():
	current_player.ui.get_node("WaveControl/CurrentLabel").text = (tr("WAVECOUNT") + " " + str(current_wave))
	current_player.ui.get_node("WaveControl/TextureProgressBar").value = current_wave

func new_target():
	for i in enemies_array:
		if players_array.is_empty():
			return
		if is_instance_valid(i) and i != null:
			i.find_target(false)

func cast_update():
	match current_wave:
		3:
			altar_cast.append("planks")
		5:
			altar_cast.append("iron")
		10:
			altar_cast.append("medkit")
		13:
			altar_cast.clear()
			altar_cast.append("medkit")

func redraw_map():
	if not grass_display:
		get_parent().get_node("Test/Map/House/Grass").hide()
	else:
		get_parent().get_node("Test/Map/House/Grass").show()

func save():
	var save_dictionary = {
		"player_examined" : bestiary_objects.get("PLAYER"),
		"zombie_examined" : bestiary_objects.get("ZOMBIE"),
		"shooter_examined" : bestiary_objects.get("SHOOTER"),
		"dodger_examined" : bestiary_objects.get("DODGER"),
		"boss_examined" : bestiary_objects.get("BOSS")
	}
	return save_dictionary

func save_data():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var json_string = JSON.stringify(save())
	save_game.store_line(json_string)
 
func load_data():
	if not FileAccess.file_exists("user://savegame.save"):
		bestiary_objects.set("PLAYER",true)
		bestiary_objects.set("ZOMBIE",false)
		bestiary_objects.set("SHOOTER",false)
		bestiary_objects.set("DODGER",false)
		bestiary_objects.set("BOSS",false)
		return
	
	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			GameManager.debuglog("Parse Error: "+json.get_error_message()+" in "+json_string+" at line "+json.get_error_line())
			continue
		var node_data = json.data
		
		bestiary_objects.set("PLAYER",node_data["player_examined"])
		bestiary_objects.set("ZOMBIE",node_data["zombie_examined"])
		bestiary_objects.set("SHOOTER",node_data["shooter_examined"])
		bestiary_objects.set("DODGER",node_data["dodger_examined"])
		bestiary_objects.set("BOSS", node_data["boss_examined"])

func _on_music_player_finished():
	$MusicPlayer.play()
