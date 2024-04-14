extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func respawn():
	print_debug("door respawned")
	#monitoring = true
	#monitorable = true
	$Door/CollisionShape2D.set_deferred("disabled", false)
	$Door/Sprite.visible = true
	$Door/LightSprite.visible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func open_door():
	print_debug("open_door")
	$Door/Sprite.visible = false
	# $Door/CollisionShape2D.disabled = true
	$Door/CollisionShape2D.set_deferred("disabled", true)
	$Door/LightSprite.visible = true
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Exit_body_entered(body):
	if body.is_in_group("Player"):
		body.exit_level()
