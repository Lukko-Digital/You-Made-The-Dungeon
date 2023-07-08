extends CharacterBody2D

const RUN_SPEED: float = 180.0
const RUN_ACCEL: float = 2000.0
const RUN_DECEL: float = 2000.0
const RUN_ACCEL_AIR_FACTOR: float = 0.75

const JUMP_SPEED: float = 350
const TERMINAL_FALL_SPEED: float = 400

const SPIKE_JUMP_SPEED: float = 500

const COYOTE_TIME_SECS: float = 0.1

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var TrapCollider: Area2D = $TrapCollider

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") * 0.75
var gravity_coeff: float = 1.0
var run_speed_coeff: float = 1.0
var in_spikes: bool = false


func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_animation()

func handle_movement(delta: float) -> void:
	handle_movement_gravity(delta)
	handle_movement_run(delta)
	handle_movement_jump(delta)
	handle_trap_collisions()

	move_and_slide()

func handle_movement_gravity(delta: float) -> void:
	if in_spikes:
		run_speed_coeff = 0.25
		gravity_coeff = 0.0
		velocity.y = move_toward(velocity.y, 0, 500 * delta)
	elif not is_on_floor():
		velocity.y = move_toward(velocity.y, TERMINAL_FALL_SPEED, gravity * gravity_coeff * delta)

func handle_movement_run(delta: float) -> void:
	var direction := Input.get_action_strength("right") - Input.get_action_strength("left")
	
	var norm_vel := velocity.x / RUN_SPEED
	var norm_target_vel := direction
	var is_decelerating: bool = (norm_vel * norm_target_vel <= 0) && (abs(norm_vel) > abs(norm_target_vel))
	var accel = RUN_DECEL if is_decelerating else RUN_ACCEL
	var accel_coeff = 1 if is_on_floor() else RUN_ACCEL_AIR_FACTOR
	
	velocity.x = move_toward(velocity.x, direction * RUN_SPEED * run_speed_coeff, accel * accel_coeff * delta)

var last_jump_input: float = INF
var last_grounded: float = INF

var is_jumping: bool

func handle_movement_jump(delta: float) -> void:
	last_jump_input += delta
	last_grounded += delta
	
	if Input.is_action_just_pressed("jump"):
		last_jump_input = 0.0
	
	if is_on_floor():
		last_grounded = 0.0
		is_jumping = false
		
	if (is_on_floor() or last_grounded <= COYOTE_TIME_SECS) and last_jump_input <= COYOTE_TIME_SECS and not is_jumping:
		velocity.y = -JUMP_SPEED
		is_jumping = true
	else:
		gravity_coeff = 1.0
		
	if Input.is_action_just_released("jump") and is_jumping:
		velocity.y = max(velocity.y, -100)

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

func handle_trap_collisions():
	for body in TrapCollider.get_overlapping_bodies():
		if body.name == "Spikes":
			in_spikes = true
		elif body.is_in_group("JumpSpikes"):
			var spike_animation = body.get_node("AnimationPlayer")
			if abs(spike_animation.current_animation_position - 2.01) < 0.1:
				velocity.y = -JUMP_SPEED * 2

func _on_area_2d_body_exited(body):
	if body.name == "Spikes":
		in_spikes = false
		run_speed_coeff = 1
		gravity_coeff = 1

