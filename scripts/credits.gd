extends CanvasLayer

@onready var fade_animation: AnimationPlayer = $FadeBlack/FadeAnimation


# Called when the node enters the scene tree for the first time.
func _ready():
	fade_animation.play("fade_from_black")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_timer_timeout():
	fade_animation.play("fade_to_black")

func _on_fade_animation_animation_finished(anim_name):
	if anim_name == "fade_to_black":
		print('asdfasfadsfasdf')
		$FadeBlack.hide()
		get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
