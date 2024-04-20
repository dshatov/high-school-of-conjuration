extends KinematicBody2D

signal player_tick_processed(vec)
signal player_kill_finished
signal player_exit_finished
signal replayer_summoned(position)

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const ACCEL = 300
const MAX_SPEED_X = 120
const MAX_SPEED_FALL = 250
const FRICTION = 0.5
const GRAVITY = 700
const JUMP_FORCE = 220
const AIR_RESISTANCE = 0.2

onready var sprite = $Sprite
onready var animation = $AnimationPlayer
onready var collision_shape: CollisionShape2D = $CollisionShape2D
onready var initial_pos = position

onready var current_summoning_area: Area2D = null

var now = 0
var motion = Vector2.ZERO
var on_floor_timestamp = 0
var summon_input_timestamp = 0
var resync_timestamp = 0

func respawn():
	now = 0
	motion = Vector2.ZERO
	on_floor_timestamp = 0
	resync_timestamp = 0
	position = initial_pos
	collision_shape.disabled = false
	current_summoning_area = null


# var replayers_sync_timestamp = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	_physics_process_impl(delta)

func _physics_process_impl(delta):
	now += delta;
	var x_input = Input.get_axis("ui_left", "ui_right")
	var y_input = 0
	if Input.is_action_just_pressed("player_jump"):
		y_input = -1
	if Input.is_action_just_released("player_jump"):
		y_input = 1

	process_physics_input(x_input, y_input, delta)
	
	if Input.is_action_just_pressed("ui_down"):
		summon_input_timestamp = now
	
	if (
		is_on_floor()
		and current_summoning_area != null
		and now - summon_input_timestamp < 0.1
	):
		print_debug("replayer_summoned")
		motion = Vector2.ZERO
		#now = 0 # necessary? make sense?
		#on_floor_timestamp = 0 # necessary? make sense?
		summon_input_timestamp = 0
		current_summoning_area.use()
		current_summoning_area = null
		emit_signal("replayer_summoned", self)
	
	if now - resync_timestamp < 1:
		resync_timestamp = now
		emit_signal("player_tick_processed", Vector3(position.x, position.y, INF))
		emit_signal("player_tick_processed", Vector3(motion.x, motion.y, -INF))
		pass
	emit_signal("player_tick_processed", Vector3(x_input, y_input, delta))


func process_physics_input(x_input, y_input, delta):
	
	if x_input != 0:
		motion.x += x_input * ACCEL * delta
		motion.x = clamp(motion.x, -MAX_SPEED_X, MAX_SPEED_X)
		animation.play("run")
		sprite.flip_h = x_input < 0
	else:
		animation.play("idle")
	
	motion = move_and_slide(motion, Vector2.UP)
	
	motion.y += GRAVITY * delta
	if motion.y > MAX_SPEED_FALL:
		motion.y = MAX_SPEED_FALL
	if is_on_floor() or now - on_floor_timestamp < 0.1 and motion.y > 0:
		if x_input == 0:
			motion.x = lerp(motion.x, 0, FRICTION)
		if y_input < 0:
			on_floor_timestamp = 0
			motion.y = -JUMP_FORCE
	else:
		animation.play("jump_up")
		if y_input > 0 and motion.y < 0:
			motion.y = 0
		if x_input == 0:
			motion.x = lerp(motion.x, 0, AIR_RESISTANCE)

	if is_on_floor():
		on_floor_timestamp = now
		if abs(motion.y) < 5:
			motion.y = 0

	if abs(motion.x) < 5:
		motion.x = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func kill():
	collision_shape.disabled = true
	# TODO timer
	emit_signal("player_kill_finished")

func exit_level():
	emit_signal("player_exit_finished")
	kill()
