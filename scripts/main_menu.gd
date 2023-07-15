extends CanvasLayer

@onready var fade_animation: AnimationPlayer = $FadeBlack/FadeAnimation
# Called when the node enters the scene tree for the first time.
func _ready():
	$FadeBlack.show()
	fade_animation.play("fade_from_black")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_start_button_pressed():
	$FadeBlack.show()
	fade_animation.play("fade_to_black")
	get_tree().change_scene_to_file("res://scenes/levels/level_0.tscn")

func _on_quit_button_pressed():
	get_tree().quit()

func _on_fade_animation_animation_finished(anim_name):
	if anim_name == "fade_from_black":
		$FadeBlack.hide()
	if anim_name == "fade_to_black":
		$FadeBlack.hide()
		get_tree().change_scene_to_file("res://scenes/levels/level_0.tscn")
