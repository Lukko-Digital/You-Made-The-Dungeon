extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready():
	self.limit_smoothed = false

func _on_smooth_enable_point_body_entered(body):
	if body.name == 'player':
		self.limit_smoothed = true
