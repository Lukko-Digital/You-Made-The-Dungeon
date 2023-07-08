extends CanvasLayer

var current_interactable_npc = null
var in_interaction = false

const DIALOGUE_PATH: String = "res://assets/dialogue/dialogue.json"
var dialogue
var num_interactions

# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/VBoxContainer/NinePatchRect/DialoguePrompt.hide()
	$HBoxContainer/VBoxContainer/NinePatchRect/DialogueBox.hide()
	
	# Load dialogue json
	assert(FileAccess.file_exists(DIALOGUE_PATH), "Dialog file at %s does not exist" % DIALOGUE_PATH)
	
	var json_str = FileAccess.open(DIALOGUE_PATH, FileAccess.READ).get_as_text()
	dialogue = JSON.parse_string(json_str)
	
	# Instantiate num_interactions
	num_interactions = dialogue.duplicate()
	for name in num_interactions.keys():
		num_interactions[name] = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interact") and current_interactable_npc:
		$HBoxContainer/VBoxContainer/NinePatchRect/DialogueBox.show()
		$HBoxContainer/VBoxContainer/NinePatchRect/DialoguePrompt.hide()
		$HBoxContainer/VBoxContainer/NinePatchRect/DialogueBox/Label.text = current_interactable_npc
		load_npc_dialogue(current_interactable_npc)
		if not in_interaction:
			num_interactions[current_interactable_npc] += 1
			in_interaction = true

func _on_npc_dialogue_collider_area_entered(area):
	if area.is_in_group('npc'):
		$HBoxContainer/VBoxContainer/NinePatchRect/DialoguePrompt.show()
		current_interactable_npc = area.name


func _on_npc_dialogue_collider_area_exited(area):
	if area.is_in_group('npc'):
		$HBoxContainer/VBoxContainer/NinePatchRect/DialoguePrompt.hide()
		$HBoxContainer/VBoxContainer/NinePatchRect/DialogueBox.hide()
		current_interactable_npc = null
		in_interaction = false

func load_npc_dialogue(name):
	var dialogue_options = dialogue[name]
	var interaction_limits = dialogue_options.keys()
	interaction_limits.reverse()
	for limit in interaction_limits:
		if num_interactions[name] >= int(limit):
			print(limit)
			break
