extends Area2D

@onready var fade_animation: AnimationPlayer = $FadeBlack/FadeAnimation

func _ready():
	fade_animation.play("fade_from_black")

func _on_body_entered(body):
	if body.name == "player":
		fade_animation.play("fade_to_black")

func _on_fade_animation_animation_finished(anim_name):
	print(anim_name)
	if anim_name == "fade_to_black":
		print('asdfasdf')
		var next_level_number = int(get_tree().get_current_scene().get_name().get_slice("_", 1)) + 1
		get_tree().change_scene_to_file("res://levels/level_%s.tscn" % str(next_level_number))
