extends "res://Player.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var inputQueueCapacity: int = 300

onready var input_queue: PoolVector3Array = PoolVector3Array()

onready var input_queue_wi: int = 0
onready var input_queue_ready: bool = false

onready var player_detector_collision_shape = $PlayerDetector/CollisionShape2D
onready var player_detector = $PlayerDetector

# Called when the node enters the scene tree for the first time.
func _ready():
	is_demon = true
	print_debug("replayer ready")
	input_queue.resize(inputQueueCapacity)
	pass # Replace with function body.


func _physics_process_impl(delta):
	pass


#func respawn():
#	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Player_player_tick_processed(vec: Vector3):
	if input_queue_wi == inputQueueCapacity:
		input_queue_ready = true
		input_queue_wi = 0

	if input_queue_ready:
		player_detector.monitoring = true
		var old_vec = input_queue[input_queue_wi]
		if old_vec.z == -INF:
			motion.x = old_vec.x
			motion.y = old_vec.y
		elif old_vec.z == +INF:
			position.x = old_vec.x
			position.y = old_vec.y
		else:
			process_physics_input(old_vec.x, old_vec.y, old_vec.z)
	input_queue[input_queue_wi] = vec
	input_queue_wi += 1


func _on_PlayerDetector_body_entered(body: PhysicsBody2D):
	print_debug('_on_PlayerDetector_body_entered')
	if body.is_in_group("Player"):
		body.kill()
		pass # TODO kill
