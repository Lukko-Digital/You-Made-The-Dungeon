extends RigidBody2D

@onready var area_2d: Area2D = $Area2D
@onready var invuln_timer: Timer = $InvulnTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	invuln_timer.wait_time = 0.1
	invuln_timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not area_2d.get_overlapping_bodies().is_empty() and invuln_timer.is_stopped():
		queue_free()
