extends Node


var language : String = "en"
var vsync = DisplayServer.VSYNC_ENABLED


func _ready():
	load_data()
	
	var language_item_id = 0
	match language:
		"en":
			language_item_id = 0
		"ru":
			language_item_id = 1
	$General/MarginContainer/VBoxContainer/Language/LanguageOption.select(language_item_id)
	
	var vsync_item_id = 0
	match language:
		DisplayServer.VSYNC_ENABLED:
			vsync_item_id = 0
		DisplayServer.VSYNC_DISABLED:
			vsync_item_id = 1
		DisplayServer.VSYNC_ADAPTIVE:
			vsync_item_id = 2
		DisplayServer.VSYNC_MAILBOX:
			vsync_item_id = 3
	$Graphics/MarginContainer/VBoxContainer/Vsync/VsyncOption.select(vsync_item_id)

func save():
	var save_dictionary = {
		"language" : language,
		"vsync" : vsync
	}
	return save_dictionary

func save_data():
	var save_game = FileAccess.open("user://settings.save", FileAccess.WRITE)
	
	var json_string = JSON.stringify(save())
	
	save_game.store_line(json_string)

func load_data():
	if not FileAccess.file_exists("user://settings.save"):
		language = "en"
		TranslationServer.set_locale(language)
		vsync = DisplayServer.VSYNC_ENABLED
		DisplayServer.window_set_vsync_mode(vsync)
		return
	
	var save_game = FileAccess.open("user://settings.save", FileAccess.READ)
	
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			GameManager.debuglog("Parse Error: "+json.get_error_message()+" in "+json_string+" at line "+json.get_error_line())
			continue
		var node_data = json.data
		
		language = node_data["language"]
		vsync = node_data["vsync"]

func  _on_language_option_item_selected(index):
	var item_id = $General/MarginContainer/VBoxContainer/Language/LanguageOption.get_item_id(index)
	match item_id:
		0:
			language = "en"
		1:
			language = "ru"
	TranslationServer.set_locale(language)
	save_data()

func _on_vsync_option_item_selected(index):
	var item_id = $Graphics/MarginContainer/VBoxContainer/Vsync/VsyncOption.get_item_id(index)
	match item_id:
		0:
			vsync = DisplayServer.VSYNC_ENABLED
		1:
			vsync = DisplayServer.VSYNC_DISABLED
		2:
			vsync = DisplayServer.VSYNC_ADAPTIVE
		3:
			vsync = DisplayServer.VSYNC_MAILBOX
	DisplayServer.window_set_vsync_mode(vsync)
	save_data()


func _on_tab_selected(tab):
	$"../../Sounds/CustomizeSound".play()
