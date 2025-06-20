extends OmniLight3D


@rpc("any_peer", "call_local")
func switch_enable():
	show()

@rpc("any_peer", "call_local")
func switch_disable():
	hide()
