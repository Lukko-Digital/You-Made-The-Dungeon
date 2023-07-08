extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/VBoxContainer/NinePatchRect/DialoguePrompt.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_npc_body_entered(body):
	if body.name == "player":
		$HBoxContainer/VBoxContainer/NinePatchRect/DialoguePrompt.show()


func _on_npc_body_exited(body):
	if body.name == "player":
		$HBoxContainer/VBoxContainer/NinePatchRect/DialoguePrompt.hide()
