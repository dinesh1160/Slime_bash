extends RigidBody2D

@onready var strech_sound = $strech_sound
@onready var launch_sound = $launch_sound
@onready var collsion_sound = $collsion_sound
@onready var arrowsprite = $arrowsprite


const STRECH_LIMIT_MIN : Vector2 = Vector2(-60 , 0)
const STRECH_LIMIT_MAX : Vector2 = Vector2(0 , 60)
const IMPULSE_CONST : float = 15.0
const IMPULSE_MAX: float = 1200.0
const FIRE_DELAY : float = 0.25
const STOP_CONST : float = 0.1


var _dead : bool = false
var _dragging: bool = false
var _released: bool = false
var _start: Vector2 = Vector2.ZERO
var _drag_start: Vector2 = Vector2.ZERO
var _dragged_vector: Vector2 = Vector2.ZERO
var _last_dragged_position: Vector2 = Vector2.ZERO
var _last_drag_amount: float = 0.0
var _fired_time: float = 0.0
var _arrow_scale_x: float = 0.0
var last_collision_count: int =0


# Called when the node enters the scene tree for the first time.
func _ready():
	_start = global_position
	_arrow_scale_x = arrowsprite.scale.x	
	arrowsprite.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	update_debug_label()
	
	if _released == true:
		_fired_time += delta
		if _fired_time > FIRE_DELAY:
			play_collision()
			check_on_target()
	else:
		if _dragging == false:
			return
		else:
			if Input.is_action_just_released("drag") == true:
				release()
			else: 
				drag()
			
			
	
	
func update_debug_label() -> void:
	var s = "g_pos:%s, collision:%s\n" % [
		utils.vec_to_str(global_position),
		get_contact_count()
	]
	s+="dragging:%s , released: %s\n" % [
		_dragging,
		_released
	]
	s+="angv:%.1f , linv: %s" % [
		angular_velocity,
		utils.vec_to_str(linear_velocity)
	]
	s+="last_drag_amount:%.1f , last_dragged_position: %s\n" % [
		_last_drag_amount,
		utils.vec_to_str(_last_dragged_position)
	]
	s+="start:%s , drag_start: %s, dragvec: %s\n" % [
		utils.vec_to_str(_start),
		utils.vec_to_str(_drag_start),
		utils.vec_to_str(_dragged_vector)
	]
	SignalManager.on_update_debug_label.emit(s)
	
func arrow_scale() -> void:
	var imp_len = get_impulse().length()
	var perc = imp_len / IMPULSE_MAX
	
	arrowsprite.scale.x = (_arrow_scale_x * perc) + _arrow_scale_x
	arrowsprite.rotation = ( _start - global_position).angle()
	
	
func stopped_rolling() -> bool:
	if get_contact_count() > 0:
		if(abs(linear_velocity.y) < STOP_CONST and abs(angular_velocity) < 0.2):
			return true
	return false
	
func check_on_target() -> void:
	if stopped_rolling() == false:
		return
	var cb = get_colliding_bodies()
	if cb.size() == 0:
		return
		
	var cup = cb[0]
	if cup.is_in_group(GameManager.GROUP_CUP) == true:
		cup.die()
		die()


func play_collision() -> void:
	if(
		last_collision_count == 0
		and get_contact_count() >0
		and collsion_sound.playing == false
	):
		collsion_sound.play()

	last_collision_count = get_contact_count()
	
func release() ->void:
	_dragging = false
	_released = true
	freeze = false
	apply_central_impulse(get_impulse())
	strech_sound.stop()
	launch_sound.play()
	ScoreManager.attempt_made()
	
	arrowsprite.hide()
	
	
func get_impulse() -> Vector2:
	return _dragged_vector * -1 * IMPULSE_CONST
	
	
func grab() -> void:
	_dragging = true
	_drag_start = get_global_mouse_position()
	_last_dragged_position = _drag_start
	
	arrowsprite.show()
	
func drag() -> void:
	var gmp = get_global_mouse_position()
	
	if _last_drag_amount > 0 and strech_sound.playing == false:
		strech_sound.play()
	
	_last_drag_amount = (_last_dragged_position - gmp).length()
	_last_dragged_position = gmp
	_dragged_vector = gmp - _drag_start
	
	_dragged_vector.x = clampf(_dragged_vector.x, STRECH_LIMIT_MIN.x ,STRECH_LIMIT_MAX.x)
	_dragged_vector.y = clampf(_dragged_vector.y, STRECH_LIMIT_MIN.y ,STRECH_LIMIT_MAX.y)
	
	global_position = _start + _dragged_vector
	
	arrow_scale()
	
	
	
	
	
func die() -> void:
	if _dead == true:
		return
	_dead = true
	SignalManager.on_slime_dead.emit()
	queue_free()
	

func _on_screen_exited():
	die()


func _on_input_event(viewport, event: InputEvent, shape_idx):
	if _dragging == true or _released == true:
		return
	if event.is_action_pressed("drag") == true:
		grab()
		
