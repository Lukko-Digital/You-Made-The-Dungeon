extends CanvasLayer

var npc_interaction_available = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/VBoxContainer/NinePatchRect/DialoguePrompt.hide()
	$HBoxContainer/VBoxContainer/NinePatchRect/DialogueBox.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interact") and npc_interaction_available:
		$HBoxContainer/VBoxContainer/NinePatchRect/DialogueBox.show()
		$HBoxContainer/VBoxContainer/NinePatchRect/DialoguePrompt.hide()


func _on_npc_body_entered(body):
	if body.name == "player":
		$HBoxContainer/VBoxContainer/NinePatchRect/DialoguePrompt.show()
		npc_interaction_available = true


func _on_npc_body_exited(body):
	if body.name == "player":
		$HBoxContainer/VBoxContainer/NinePatchRect/DialoguePrompt.hide()
		$HBoxContainer/VBoxContainer/NinePatchRect/DialogueBox.hide()
		npc_interaction_available = false
