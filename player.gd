extends CharacterBody3D

@onready var head = $Head
@onready var StandingCollision = $StandingCollisionShape3D
@onready var CrouchingCollision = $CrouchingCollisionShape3D
@onready var RayCastPlayer = $RayCastPlayer

@export var LERP_SPEED = 10.0
@export var CROUCHING_SPEED = 2.5
@export var CROUCHING_DEPTH = -0.5
@export var WALKING_SPEED = 5.0
@export var RUNNING_SPEED = 10.0
@export var JUMP_VELOCITY = 4.5
@export var MOUSE_SENSITIVITY = .35

var direction = Vector3.ZERO
var CURRENT_SPEED = 5.0

func _ready():
	# Lock the mouse to the middle of the screen and hide it
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# Rotate the player head along the X,Y axis
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta: float):
	
	# Handle running
	if Input.is_action_pressed("crouch"):
		CURRENT_SPEED = CROUCHING_SPEED
		head.position.y = lerp(head.position.y, 1.8 + CROUCHING_DEPTH, delta * LERP_SPEED)
		StandingCollision.disabled = true
		CrouchingCollision.disabled = false
	elif !RayCastPlayer.is_colliding():
		StandingCollision.disabled = false
		CrouchingCollision.disabled = true
		head.position.y = lerp(head.position.y, 1.8, delta * LERP_SPEED)
		if Input.is_action_pressed("run"):
			CURRENT_SPEED = RUNNING_SPEED
		else:
			CURRENT_SPEED = WALKING_SPEED
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and !Input.is_action_pressed("crouch") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*LERP_SPEED)
	if direction:
		velocity.x = direction.x * CURRENT_SPEED
		velocity.z = direction.z * CURRENT_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, CURRENT_SPEED)
		velocity.z = move_toward(velocity.z, 0, CURRENT_SPEED)

	move_and_slide()
