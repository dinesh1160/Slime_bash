extends Node

const DEFAULT_SCORE: int = 0
var _level_score: Dictionary ={}
var _level_selected: int =0
var attempts: int =0
var cups_hit: int =0
var _target_cups : int = 0 
 



# Called when the node enters the scene tree for the first time.
func _ready():
	SignalManager.on_cup_destroyed.connect(on_cup_destroyed)
	
func check_and_add(level: int) -> void:
	if _level_score.has(level) == false:
		_level_score[level] = DEFAULT_SCORE
		
func level_selected(level: int) -> void:
	check_and_add(level)
	_level_selected = level
	attempts = 0
	cups_hit = 0
	print("_level_selected:%s _level_scores:%s" % [
		level_selected , _level_score
	]) 
		
func get_best_score_level(level: int) -> int:
	check_and_add(level)
	return _level_score[level]
	
func get_attempts() -> int:
	return attempts
	
func get_level_selected() -> int:
	return _level_selected

func set_target_cups(t: int) -> void:
	_target_cups = t
	print("set_target_cups:", _target_cups)
	
func attempt_made()->void:
	attempts+=1
	SignalManager.on_attempt_made.emit()
	print("attempts_made()  _target_cups:%s,,attempts:%s,cups_hit:%s"%[
		_target_cups,attempts,cups_hit
	])
	
	
	
func check_game_over() -> void:
	if cups_hit >= _target_cups:
		print("game over", _level_score)
		SignalManager.on_game_over.emit()
		if _level_score[_level_selected] < attempts:
			_level_score[_level_selected] = attempts
			print("Record:", _level_score )
	


func on_cup_destroyed() -> void:
	cups_hit += 1
	print("on_cup_destroyed  _target_cups:%s,,attempts:%s,cups_hit:%s"%[
		_target_cups,attempts,cups_hit
	])
	check_game_over()
