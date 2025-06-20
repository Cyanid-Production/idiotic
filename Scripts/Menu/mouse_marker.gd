extends Node3D


@onready var camera : Camera3D = $"../Camera3D"
var active : bool = true

func _physics_process(delta):
	if not active: return
	var mouse_position = get_viewport().get_mouse_position()
	var ray_start = camera.project_ray_origin(mouse_position)
	var direction = camera.project_ray_normal(mouse_position)
	var plane = Plane(Vector3.UP)
	
	var intersection = plane.intersects_ray(ray_start, direction)
	
	if intersection:
		global_position.x = intersection.x
		global_position.z = intersection.z
