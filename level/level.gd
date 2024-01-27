extends Node2D

var slime_scene: PackedScene = preload("res://slime/slime.tscn")

@onready var slimeposition = $slimeposition
@onready var debug_label = $DebugLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	setup()
	SignalManager.on_update_debug_label.connect(on_update_debug_label)
	SignalManager.on_slime_dead.connect(on_slime_dead)
	on_slime_dead()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_Q) == true:
		GameManager.load_main_scene()
		
func setup() -> void:
	var tc = get_tree().get_nodes_in_group(GameManager.GROUP_CUP)
	ScoreManager.set_target_cups(tc.size())
	
	
func on_slime_dead() -> void:
	var slime = slime_scene.instantiate()
	slime.global_position = slimeposition.global_position
	add_child(slime)

func on_update_debug_label(text: String) -> void:
	debug_label.text = text
	
