extends StaticBody2D

var dart_scene = preload("res://scenes/dart.tscn")

func _on_line_of_sight_body_entered(body):
	var new_dart = dart_scene.instantiate()
	
	new_dart.linear_velocity.x = scale.x * -375
	
	add_child(new_dart)
	
	
