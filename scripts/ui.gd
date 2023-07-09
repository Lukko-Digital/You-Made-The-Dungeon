extends CanvasLayer

var current_interactable_npc = null
var in_interaction = false

const DIALOGUE_PATH: String = "res://assets/dialogue/dialogue.json"
var dialogue
var num_interactions
var current_dialogue_idx = 0

@onready var dialogue_prompt: Control = $HBoxContainer/VBoxContainer/MarginContainer2/DialoguePrompt
@onready var dialogue_box: NinePatchRect = $HBoxContainer/VBoxContainer/MarginContainer2/DialogueBox
@onready var name_label: Label = $HBoxContainer/VBoxContainer/MarginContainer2/DialogueBox/VBoxContainer/HBoxContainer/Text/Name
@onready var dialogue_label: Label = 	$HBoxContainer/VBoxContainer/MarginContainer2/DialogueBox/VBoxContainer/HBoxContainer/Text/Dialogue

const TEXT_SPEED = 0.05

# Called when the node enters the scene tree for the first time.
func _ready():
	dialogue_prompt.hide()
	dialogue_box.hide()
	
	$HBoxContainer/VBoxContainer/MarginContainer2/DialogueBox/TextTimer.wait_time = TEXT_SPEED
	
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
#		dialogue_prompt.hide()
#		$HBoxContainer/VBoxContainer/MarginContainer2/DialogueBox/Label.text = 'asdf'
		load_npc_dialogue(current_interactable_npc)
		if not in_interaction:
			in_interaction = true

func _on_npc_dialogue_collider_area_entered(area):
	if area.is_in_group('npc'):
		dialogue_prompt.show()
		current_interactable_npc = area.name


func _on_npc_dialogue_collider_area_exited(area):
	if area.is_in_group('npc'):
		dialogue_prompt.hide()
		dialogue_box.hide()
		current_dialogue_idx = 0
		current_interactable_npc = null
		in_interaction = false
		

func load_npc_dialogue(name):
	var dialogue_list = get_dialogue_list(name)
	handle_dialogue_display(dialogue_list)
	
func get_dialogue_list(name):
	var dialogue_options = dialogue[name]
	var interaction_limits = dialogue_options.keys()
	interaction_limits.reverse()
	for limit in interaction_limits:
		if num_interactions[name] >= int(limit):
			return dialogue_options[str(limit)]

func handle_dialogue_display(dialogue_list):
	if current_dialogue_idx >= len(dialogue_list):
		dialogue_box.hide()
		dialogue_prompt.show()
		num_interactions[current_interactable_npc] += 1
		current_dialogue_idx = 0
		return
	
	dialogue_box.show()
	dialogue_prompt.hide()
	name_label.text = current_interactable_npc
	dialogue_label.text = dialogue_list[current_dialogue_idx]
	
	current_dialogue_idx += 1
