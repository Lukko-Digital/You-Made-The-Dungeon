extends CanvasLayer

var npc_interaction_available = false

const DIALOGUE_PATH: String = "res://assets/dialogue/dialogue.json"
var dialog

# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/VBoxContainer/NinePatchRect/DialoguePrompt.hide()
	$HBoxContainer/VBoxContainer/NinePatchRect/DialogueBox.hide()
	
	assert(FileAccess.file_exists(DIALOGUE_PATH), "Dialog file at `res://assets/dialogue/dialogue.json` does not exist")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interact") and npc_interaction_available:
		$HBoxContainer/VBoxContainer/NinePatchRect/DialogueBox.show()
		$HBoxContainer/VBoxContainer/NinePatchRect/DialoguePrompt.hide()

func _on_npc_dialogue_collider_area_entered(area):
	if area.is_in_group('npc'):
		$HBoxContainer/VBoxContainer/NinePatchRect/DialoguePrompt.show()
		npc_interaction_available = true


func _on_npc_dialogue_collider_area_exited(area):
	if area.is_in_group('npc'):
		$HBoxContainer/VBoxContainer/NinePatchRect/DialoguePrompt.hide()
		$HBoxContainer/VBoxContainer/NinePatchRect/DialogueBox.hide()
		npc_interaction_available = false
