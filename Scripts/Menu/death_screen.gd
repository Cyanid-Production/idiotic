extends Control


func _ready():
	$Label.text = tr("DEATH_"+str(randi_range(1,6)))
	$AnimationPlayer.play("appear_1")
	$AudioStreamPlayer.play()


func _on_timer_timeout():
	get_tree().change_scene_to_file("res://Scenes/Test.tscn")
