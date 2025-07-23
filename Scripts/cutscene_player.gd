extends CharacterBody3D


const SPEED = 2.5
const JUMP_VELOCITY = 4.0

@onready var camera : Camera3D = $Camera3D


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		camera.rotate_x(-event.relative.y * 0.005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * 1.5 * delta
	
	if Input.is_action_just_pressed("ui_accept"):
		$JumpTimer.start()
	
	if not $JumpTimer.is_stopped() and is_on_floor():
		velocity.y += JUMP_VELOCITY
	
	var input_dir = Input.get_vector("go_left", "go_right", "go_forward", "go_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		if $Timer.is_stopped():
			$StepSound.play()
			$Timer.start()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
