extends CharacterBody2D

const RUN_SPEED: float = 180.0
const RUN_ACCEL: float = 2000.0
const RUN_DECEL: float = 2000.0
const RUN_ACCEL_AIR_FACTOR: float = 0.75

const CLIMB_SPEED: float = 50.0

const JUMP_SPEED: float = 350
const TERMINAL_FALL_SPEED: float = 400

const SPIKE_JUMP_SPEED: float = 500

const COYOTE_TIME_SECS: float = 0.1

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var LegsCollider: Area2D = $LegsCollider
@onready var ChestCollider: Area2D = $ChestCollider
@onready var HeadCollider: Area2D = $HeadCollider

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity") * 0.75
var gravity_coeff: float = 1.0
var is_on_spikes: bool = false
var is_on_vines: bool = false
var is_on_dart: bool = false
var jumping_off_dart: bool = false


func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_animation()

func handle_movement(delta: float) -> void:
	handle_movement_gravity(delta)
	handle_movement_run(delta)
	handle_movement_jump(delta)
	handle_trap_collisions(delta)

	move_and_slide()

func handle_movement_gravity(delta: float) -> void:
	if is_on_spikes or is_on_vines:
		gravity_coeff = 0.0
		velocity.y = move_toward(velocity.y, 0, 500 * delta)
		
		if abs(velocity.x) > 0 or abs(velocity.y) > 0:
			animation_tree["parameters/conditions/moving"] = true
		else:
			animation_tree["parameters/conditions/moving"] = false
	elif not is_on_floor():
		velocity.y = move_toward(velocity.y, TERMINAL_FALL_SPEED, gravity * gravity_coeff * delta)

func handle_movement_run(delta: float) -> void:
	var direction := Input.get_action_strength("right") - Input.get_action_strength("left")
	
	var norm_vel := velocity.x / RUN_SPEED
	var norm_target_vel := direction
	var is_decelerating: bool = (norm_vel * norm_target_vel <= 0) && (abs(norm_vel) > abs(norm_target_vel))
	var accel = RUN_DECEL if is_decelerating else RUN_ACCEL
	var accel_coeff = 1 if is_on_floor() else RUN_ACCEL_AIR_FACTOR
	
	var max_speed = direction * CLIMB_SPEED if (is_on_spikes or is_on_vines) else direction * RUN_SPEED
	velocity.x = move_toward(velocity.x, max_speed, accel * accel_coeff * delta)
	
	if is_on_vines:
		var y_direction := Input.get_action_strength("down") - Input.get_action_strength("up")
		velocity.y = y_direction * CLIMB_SPEED
	
	if is_on_spikes:
		if Input.is_action_just_pressed("down"):
			animation_tree["parameters/conditions/climb"] = false
			animation_tree["parameters/conditions/not_climb"] = true
			animation_tree["parameters/conditions/moving"] = false
			is_on_spikes = false
			gravity_coeff = 1

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
	elif is_on_dart and last_jump_input <= COYOTE_TIME_SECS and not is_jumping:
		velocity.y = -JUMP_SPEED
		is_jumping = true
		jumping_off_dart = true
	elif is_on_vines and last_jump_input <= COYOTE_TIME_SECS and not is_jumping:
		velocity.y = -JUMP_SPEED
		is_jumping = true
		animation_tree["parameters/conditions/climb"] = false
		animation_tree["parameters/conditions/not_climb"] = true
		animation_tree["parameters/conditions/moving"] = false
		is_on_vines = false
		gravity_coeff = 1
	else:
		gravity_coeff = 1.0
		
	if Input.is_action_just_released("jump") and is_jumping:
		velocity.y = max(velocity.y, -100)

func handle_animation():
	# Determine input direction
	var direction = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	# Scale character horizontally to make them face the direction of velocity at all times
	if velocity.x != 0:
		sprite_2d["scale"] = Vector2(sign(velocity.x), 1)
	
	# Jumping Case
	if not is_on_floor():
		animation_tree["parameters/default/conditions/grounded"] = false
		animation_tree["parameters/default/conditions/airborne"] = true
		animation_tree["parameters/default/land/blend_position"] = ((abs(direction)-.5)*2)
		animation_tree["parameters/default/airborne/blend_position"] = Vector2((((abs(velocity.x)/RUN_SPEED)-.5)*2), sign(velocity.y)) # Expression for the first number in this vector 2 turns our x velocity into a number where -1 represents not moving, while 1 represents full speed.
		return # Grounded case is not executed
	
	# Grounded Case
	animation_tree["parameters/default/grounded/blend_position"] = (((abs(velocity.x)/RUN_SPEED)-.5)*2)
	animation_tree["parameters/default/conditions/grounded"] = true
	animation_tree["parameters/default/conditions/airborne"] = false

func handle_climbing(body):
	#"Spikes" is the tilemap with the stationary spikes
	if body.name == "Vines" and velocity.y > 0:
		is_on_vines = true
		animation_tree["parameters/conditions/climb"] = true
		animation_tree["parameters/conditions/not_climb"] = false
		is_jumping = false

#Called when you jump off the dart or hit a wall
func off_dart(body):
	animation_tree["parameters/conditions/shot_head"] = false
	animation_tree["parameters/conditions/shot_body"] = false
	animation_tree["parameters/conditions/not_shot"] = true
	body.queue_free()
	is_on_dart = false
	jumping_off_dart = false
	
func on_dart(body):
	#Sets velocity/position equal to darts velocity/position
	velocity = body.linear_velocity
	global_position.y = body.global_position.y - 1
	body.visible = false
	is_on_dart = true
	is_jumping = false

func handle_trap_collisions(delta):
	#legs only collide with spikes
	for body in LegsCollider.get_overlapping_bodies():
		if body.is_in_group("JumpSpikes"):
			var spike_animation = body.get_node("AnimationPlayer")
			#The spikes pop up at 2 seconds in the animation
			#Checks if the animation is within 0.2 seconds of poping up
			if abs(spike_animation.current_animation_position - 2.01) < 0.1:
				velocity.y = -JUMP_SPEED * 2
				is_jumping = false

	#body can collide with spikes and darts (dart code is reused but only changed for which animation to run
	for body in ChestCollider.get_overlapping_bodies():
		handle_climbing(body)
		if body.is_in_group("Darts"):
			if (not is_on_wall() or not is_on_dart) and not jumping_off_dart:
				#Changes animation
				animation_tree["parameters/conditions/shot_body"] = true
				animation_tree["parameters/conditions/shot_head"] = false
				animation_tree["parameters/conditions/not_shot"] = false
				on_dart(body)
			else:
				off_dart(body)

	for body in HeadCollider.get_overlapping_bodies():
		if body.is_in_group("Darts") and not animation_tree["parameters/conditions/shot_body"]:
			if (not is_on_wall() or not is_on_dart) and not jumping_off_dart:
				animation_tree["parameters/conditions/shot_head"] = true
				animation_tree["parameters/conditions/shot_body"] = false
				animation_tree["parameters/conditions/not_shot"] = false
				on_dart(body)
			else:
				off_dart(body)

func _on_area_2d_body_exited(body):
	if body.name == "Spikes":
		animation_tree["parameters/conditions/climb"] = false
		animation_tree["parameters/conditions/not_climb"] = true
		animation_tree["parameters/conditions/moving"] = false
		is_on_spikes = false
		gravity_coeff = 1
	if body.name == "Vines":
		animation_tree["parameters/conditions/climb"] = false
		animation_tree["parameters/conditions/not_climb"] = true
		animation_tree["parameters/conditions/moving"] = false
		is_on_vines = false
		gravity_coeff = 1
	


func _on_chest_collider_body_entered(body):
	if body.name == "Spikes":
		is_on_spikes = true
		animation_tree["parameters/conditions/climb"] = true
		animation_tree["parameters/conditions/not_climb"] = false

func _on_legs_collider_body_entered(body):
	if body.name == "Spikes":
		is_on_spikes = true
		animation_tree["parameters/conditions/climb"] = true
		animation_tree["parameters/conditions/not_climb"] = false
