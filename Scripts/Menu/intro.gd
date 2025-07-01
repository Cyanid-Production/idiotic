extends Control


func _enter_tree():
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _on_animation_player_animation_finished(anim_name):
	get_tree().change_scene_to_file("res://Scenes/Test.tscn")
