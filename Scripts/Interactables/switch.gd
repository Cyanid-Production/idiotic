extends StaticBody3D


@export var item_to_use : Node
var current_state : bool = false

@rpc("any_peer", "call_local")
func use(usr):
	if $AnimationPlayer.is_playing():
		return
	match current_state:
		true:
			$AnimationPlayer.play("disable_switch")
		false:
			$AnimationPlayer.play("enable_switch")

func _on_animation_player_animation_finished(anim_name):
	current_state = !current_state
	if item_to_use != null:
		if current_state:
			item_to_use.switch_enable.rpc()
		else:
			item_to_use.switch_disable.rpc()
