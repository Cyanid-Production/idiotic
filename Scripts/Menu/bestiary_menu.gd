extends Control


var bestiary_array : Array[String] = [
	"PLAYER",
	"ZOMBIE",
	"SHOOTER",
	"DODGER",
	"BOSS"
]


func _ready():
	for i in bestiary_array:
		var new_button = BestiaryButton.new()
		new_button.text = (i + "_NAME")
		new_button.id = i
		if not GameManager.bestiary_objects.get(i):
			new_button.text = "???"
			new_button.disabled = true
		$ArrayContainer.add_child(new_button)
