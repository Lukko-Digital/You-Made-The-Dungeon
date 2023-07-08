extends CanvasLayer

var npc_interaction_available = false

const DIALOGUE_PATH: String = "res://assets/dialogue/dialogue.json"
var dialog
var num_interactions

# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/VBoxContainer/NinePatchRect/DialoguePrompt.hide()
	$HBoxContainer/VBoxContainer/NinePatchRect/DialogueBox.hide()
	
	# Load dialogue json
	assert(FileAccess.file_exists(DIALOGUE_PATH), "Dialog file at %s does not exist" % DIALOGUE_PATH)
	
	var json_str = FileAccess.open(DIALOGUE_PATH, FileAccess.READ).get_as_text()
	dialog = JSON.parse_string(json_str)
	
	# Instantiate num_interactions
	num_interactions = dialog.duplicate()
	for name in num_interactions.keys():
		num_interactions[name] = 0
		
	print(num_interactions)


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
