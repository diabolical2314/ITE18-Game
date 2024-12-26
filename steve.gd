extends CharacterBody3D

# Constants for movement and jump behavior
const SPEED = 8.0
const JUMP_VELOCITY = 13.0

# Reference to transform (for floor alignment)
var xform: Transform3D

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Play animations based on character state
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		$AnimationPlayer.play("jump")
	elif is_on_floor() and input_dir != Vector2.ZERO:
		$AnimationPlayer.play("run")
	elif is_on_floor() and input_dir == Vector2.ZERO:
		$AnimationPlayer.play("idle")

	# Camera rotation inputs (left and right)
	handle_camera_rotation()

	# Apply gravity and handle jumping when on the floor
	if not is_on_floor():
		velocity += get_gravity() * delta  # Gravity effect
	else:
		velocity.y = 0  # Reset velocity.y when grounded

	# Handle jumping when on the floor
	handle_jump()

	# Handle character movement and orientation
	handle_movement(delta)

	# Align character with the floor normal (if on the floor)
	if is_on_floor():
		align_with_floor($RayCast3D.get_collision_normal())
	else:
		align_with_floor(Vector3.UP)

	# Update character's global transform smoothly
	global_transform = global_transform.interpolate_with(xform, 0.3)

	# Update position and camera controller position to follow the character
	update_camera_position()


# Camera rotation handling based on player input
func handle_camera_rotation() -> void:
	if Input.is_action_just_pressed("cam_left"):
		$Camera_Controller.rotate_y(deg_to_rad(-30))

	if Input.is_action_just_pressed("cam_right"):
		$Camera_Controller.rotate_y(deg_to_rad(30))


# Jumping behavior
func handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY


# Character movement and orientation handling
func handle_movement(delta: float) -> void:
	# Get the movement input direction
	var input_dir := Input.get_vector("ui_right", "ui_left", "ui_up", "ui_down")

	# Check if there's any input
	if input_dir != Vector2.ZERO:
		# New Vector3 Direction considering camera rotation
		# We negate input_dir.x to fix left/right inversion
		var direction = ($Camera_Controller.transform.basis * Vector3(-input_dir.x, 0, input_dir.y)).normalized()

		# Apply movement
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		# Update the character's rotation based on movement direction and camera orientation
		var target_angle = rad_to_deg(input_dir.angle()) + $Camera_Controller.rotation_degrees.y
		$Armature.rotation_degrees.y = target_angle

	else:
		# No input, stop immediately
		velocity.x = 0
		velocity.z = 0

	# Move the character using physics
	move_and_slide()  # Make sure to pass the velocity to move_and_slide()


# Align character with the floor based on the floor normal
func align_with_floor(floor_normal: Vector3) -> void:
	xform = global_transform
	# Align the basis to floor normal
	xform.basis.y = floor_normal
	# Recalculate the x-axis to be perpendicular to the floor normal
	xform.basis.x = -xform.basis.z.cross(floor_normal)
	# Ensure the basis is orthonormal
	xform.basis = xform.basis.orthonormalized()
	# Apply the alignment transformation
	global_transform = xform


# Update camera position to follow the character (without smoothing)
func update_camera_position() -> void:
	$Camera_Controller.position = position


# On entering the fall zone
func _on_fall_zone_body_shape_entered(body_rid: RID, body: Node3D, body_shape_index: int, local_shape_index: int) -> void:
	get_tree().change_scene_to_file("res://level_1.tscn")
