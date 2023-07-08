extends CharacterBody2D

const RUN_SPEED: float = 180.0
const RUN_ACCEL: float = 2000.0
const RUN_DECEL: float = 2000.0
const RUN_ACCEL_AIR_FACTOR: float = 0.75

const JUMP_SPEED: float = 350
const TERMINAL_FALL_SPEED: float = 400

const COYOTE_TIME_SECS: float = 0.1

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite_2d: Sprite2D = $Sprite2D

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") * 0.75
var gravity_coeff: float = 1.0


func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_animation()

func handle_movement(delta: float) -> void:
	handle_movement_gravity(delta)
	handle_movement_run(delta)
	handle_movement_jump(delta)

	move_and_slide()

func handle_movement_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y = move_toward(velocity.y, TERMINAL_FALL_SPEED, gravity * gravity_coeff * delta)

func handle_movement_run(delta: float) -> void:
	var direction := Input.get_action_strength("right") - Input.get_action_strength("left")
	
	var norm_vel := velocity.x / RUN_SPEED
	var norm_target_vel := direction
	var is_decelerating: bool = (norm_vel * norm_target_vel <= 0) && (abs(norm_vel) > abs(norm_target_vel))
	var accel = RUN_DECEL if is_decelerating else RUN_ACCEL
	var accel_coeff = 1 if is_on_floor() else RUN_ACCEL_AIR_FACTOR
	
	velocity.x = move_toward(velocity.x, direction * RUN_SPEED, accel * accel_coeff * delta)

var buffer_time = 0;

func handle_movement_jump(delta: float) -> void:
	
	if buffer_time > 0:
		if is_on_floor():
			velocity += Vector2.UP * JUMP_SPEED
			buffer_time = 0
		else:
			buffer_time -= delta
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity += Vector2.UP * JUMP_SPEED
		else:
			buffer_time = COYOTE_TIME_SECS
			
		
	if velocity.y < -100 and Input.is_action_just_released("jump"):
		velocity.y = -100

func handle_animation():
	# Determine input direction
	var direction = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	# Scale character horizontally to make them face the direction of input at all times
	if direction != 0:
		sprite_2d["scale"] = Vector2(sign(direction), 1)
	
	# Jumping Case
	if not is_on_floor():
		animation_tree["parameters/conditions/grounded"] = false
		animation_tree["parameters/conditions/airborne"] = true
		animation_tree["parameters/land/blend_position"] = ((abs(direction)-.5)*2)
		animation_tree["parameters/airborne/blend_position"] = Vector2((((abs(velocity.x)/RUN_SPEED)-.5)*2), sign(velocity.y)) # Expression for the first number in this vector 2 turns our x velocity into a number where -1 represents not moving, while 1 represents full speed.
		return # Grounded case is not executed
	
	# Grounded Case
	animation_tree["parameters/grounded/blend_position"] = (((abs(velocity.x)/RUN_SPEED)-.5)*2)
	animation_tree["parameters/conditions/grounded"] = true
	animation_tree["parameters/conditions/airborne"] = false


func _on_area_2d_body_entered(body):
	print(body.name)
	pass # Replace with function body.
