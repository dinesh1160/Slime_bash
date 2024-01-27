extends Node


const GROUP_CUP: String = "cup"
const GROUP_SLIME: String = "slime"

var main_scene : PackedScene = preload("res://main/main.tscn")

func load_main_scene() -> void:
	get_tree().change_scene_to_packed(main_scene)
