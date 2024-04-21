extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var now: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	now += delta
	
	var seconds: float = fmod(now , 60.0)
	var minutes: int =  int(now / 60.0)
	text = "%02d:%05.2f" % [minutes, seconds]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
