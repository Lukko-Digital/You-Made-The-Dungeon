extends CanvasLayer

var current_interactable_npc = null
var in_interaction = false

const DIALOGUE_PATH: String = "res://assets/dialogue/dialogue.json"
const VOICE_PITCH_MIN: float = 0.9
const VOICE_PITCH_MAX: float = 1.5

var dialogue
var num_interactions
var current_dialogue_idx = 0
var display_in_progress = false
var rng = RandomNumberGenerator.new()

@onready var dialogue_prompt: Control = $HBoxContainer/VBoxContainer/MarginContainer2/DialoguePrompt
@onready var dialogue_box: NinePatchRect = $HBoxContainer/VBoxContainer/MarginContainer2/DialogueBox
@onready var name_label: Label = $HBoxContainer/VBoxContainer/MarginContainer2/DialogueBox/VBoxContainer/HBoxContainer/Text/Name
@onready var dialogue_label: Label = 	$HBoxContainer/VBoxContainer/MarginContainer2/DialogueBox/VBoxContainer/HBoxContainer/Text/Dialogue
@onready var text_timer: Timer = $HBoxContainer/VBoxContainer/MarginContainer2/DialogueBox/TextTimer
@onready var dialogue_noise: AudioStreamPlayer = $HBoxContainer/VBoxContainer/MarginContainer2/DialogueBox/AudioStreamPlayer

const TEXT_SPEED = 0.04

# Called when the node enters the scene tree for the first time.
func _ready():
	dialogue_prompt.hide()
	dialogue_box.hide()
	
	text_timer.wait_time = TEXT_SPEED
	
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
		if display_in_progress:
			dialogue_label.visible_characters = len(dialogue_label.text)
		else:
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
	
	# handle visablilty
	dialogue_box.show()
	dialogue_prompt.hide()
	
	# set text
	name_label.text = current_interactable_npc
	dialogue_label.text = dialogue_list[current_dialogue_idx]
	
	# animation
	dialogue_label.visible_characters = 0
	display_in_progress = true
	
	while dialogue_label.visible_characters < len(dialogue_label.text):
		dialogue_noise.pitch_scale = rng.randf_range(VOICE_PITCH_MIN, VOICE_PITCH_MAX)
		dialogue_noise.play()
		dialogue_label.visible_characters += 1
		text_timer.start()
		await text_timer.timeout
	
	display_in_progress = false
	current_dialogue_idx += 1
