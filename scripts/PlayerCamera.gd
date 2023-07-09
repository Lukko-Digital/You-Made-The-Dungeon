extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	self.limit_smoothed = false
	$EnableSmoothTimer.start(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_enable_smooth_timer_timeout():
	self.limit_smoothed = true
	print("1")
