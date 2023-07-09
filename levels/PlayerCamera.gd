extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	self.position_smoothing_enabled = false
	$EnableSmoothTimer.start(0.01)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_enable_smooth_timer_timeout():
	self.position_smoothing_enabled = true
