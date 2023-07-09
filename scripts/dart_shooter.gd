extends StaticBody2D

var dart_scene = preload("res://scenes/dart.tscn")

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_timer: Timer = $Timer

func _on_line_of_sight_body_entered(body):
	animation_tree["parameters/conditions/shoot"] = true
	animation_timer.start(0.69)
	
	var new_dart = dart_scene.instantiate()
	new_dart.linear_velocity.x = scale.x * -375
	call_deferred("add_child", new_dart)

func _on_timer_timeout():
	animation_tree["parameters/conditions/shoot"] = false
