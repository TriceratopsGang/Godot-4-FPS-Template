class_name PlayerCharacter extends CharacterBody3D


@export_group("References")
@export var fps_camera: Camera3D = null

@export_group("Movement")
@export_range(1.0, 10.0) var speed: float = 5.0
@export_range(1.0, 32.0) var acceleration: float = 8.0
@export_range(1.0, 32.0) var deceleration: float = 16.0
@export_range(0.01, 10.0) var gravity_scalar: float = 1.0
@export_range(1.0, 10.0) var jump_velocity: float = 5.0
@export_range(0.0, 1.0) var air_control: float = 0.2

@export_group("Camera")
@export_range(0.01, 10.0, 0.01) var sensitivity_scalar: float = 0.01
@export_range(0.01, 100.0, 0.01) var yaw_sensitivity: float = 0.25
@export_range(0.01, 100.0, 0.01) var pitch_sensitivity: float = 0.25
@export_range(38.0, 92.0, 1.0) var default_fov: float = 60.0
@export_range(1.0, 5.0, 0.1) var zoom_scalar: float = 2.0
@export_range(1.0, 5.0, 0.1) var zoom_duration: float = 0.2

const PITCH_CLAMP: float = deg_to_rad(89.0)
const MIN_FOV: float = 18.0
const MAX_FOV: float = 112.0

var input_direction: Vector2
var move_direction: Vector3


func _init() -> void:
	Global.player = self

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	adjust_camera_fov(default_fov)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		handle_jumping()

	if event.is_action_pressed("zoom"):
		handle_zooming(true)
	elif event.is_action_released("zoom"):
		handle_zooming(false)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		handle_look(event)

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_movement(delta)

	apply_final_velocity()

func handle_look(event: InputEvent) -> void:
	rotate_y((-event.relative.x * yaw_sensitivity) * sensitivity_scalar)
	fps_camera.rotate_x((-event.relative.y * pitch_sensitivity) * sensitivity_scalar)
	fps_camera.rotation.x = clampf(fps_camera.rotation.x, -PITCH_CLAMP, PITCH_CLAMP)

func apply_final_velocity() -> void:
	move_and_slide()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += (get_gravity() * gravity_scalar) * delta

func handle_movement(delta: float) -> void:
	input_direction = Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
	move_direction = (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()

	#This is repetitive and I should look into simplier approach.
	if is_on_floor():
		if move_direction:
			velocity.x = lerpf(velocity.x, move_direction.x * speed, acceleration * delta)
			velocity.z = lerpf(velocity.z, move_direction.z * speed, acceleration * delta)
		else:
			velocity.x = lerpf(velocity.x, 0.0, deceleration * delta)
			velocity.z = lerpf(velocity.z, 0.0, deceleration * delta)
	else:
		if move_direction:
			velocity.x = lerpf(velocity.x, move_direction.x * speed, acceleration * delta * air_control)
			velocity.z = lerpf(velocity.z, move_direction.z * speed, acceleration * delta * air_control)
		else:
			velocity.x = lerpf(velocity.x, 0.0, deceleration * delta * air_control)
			velocity.z = lerpf(velocity.z, 0.0, deceleration * delta * air_control)

func handle_jumping() -> void:
	if is_on_floor():
		velocity.y = jump_velocity

func handle_zooming(state: bool) -> void:
	var tween: Tween = create_tween()
	var target_fov: float = default_fov / zoom_scalar if state else default_fov

	tween.tween_method(adjust_camera_fov, fps_camera.fov, target_fov, zoom_duration)

func adjust_camera_fov(value: float) -> void:
	value = clampf(value, MIN_FOV, MAX_FOV)
	fps_camera.fov = value
