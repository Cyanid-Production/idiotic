extends Area3D


var charge : int = 0


@rpc("call_local", "any_peer")
func use(usr):
	if charge > 0:
		charge -= 1
		$RechargeTimer.wait_time += 5.0
		GameManager.get_player(usr).add_to_inventory(GameManager.altar_cast.pick_random())
	if charge <= 0:
			$MeshInstance3D.hide()

func _on_recharge_timer_timeout():
	charge += 1
	if charge > 0:
		$MeshInstance3D.show()
		$ChargeSound.play()
