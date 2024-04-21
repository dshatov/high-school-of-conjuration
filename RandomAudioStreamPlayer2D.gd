extends AudioStreamPlayer2D

export(Array, AudioStream) var streams
export(float) var throttling_sec = 0.0

var rng = RandomNumberGenerator.new()
var now = 0
var last_sample_idx = -1

onready var last_played = -throttling_sec

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	pass # Replace with function body.

func play(from_position: float = 0.0):
	if now < last_played + throttling_sec:
		return
	last_played = now
	var n = streams.size()
	if n == 0:
		return
	var sample_idx = last_sample_idx
	while last_sample_idx == sample_idx and n > 1:
		sample_idx = rng.randi() % n
	last_sample_idx = sample_idx
	stream = streams[sample_idx]
	.play(from_position)

func _physics_process(delta):
	now += delta

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
