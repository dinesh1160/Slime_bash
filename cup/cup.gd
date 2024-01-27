extends StaticBody2D

@onready var animation_player = $AnimationPlayer
@onready var vanish_sound = $vanish_sound


func die() -> void:
	animation_player.play("vanish")
	vanish_sound.play()
	


func _on_vanish_sound_finished():
	SignalManager.on_cup_destroyed.emit()
	queue_free()
