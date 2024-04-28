extends AudioStreamPlayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var _fade_in: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func _physics_process(delta):
	pass
	var linear_volume = db2linear(volume_db)
	linear_volume = clamp(linear_volume + (delta if _fade_in else -delta) / 2, 0, 1)
	volume_db = linear2db(linear_volume)
