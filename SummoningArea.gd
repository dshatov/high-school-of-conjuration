extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var sprite = $Sprite
onready var light_sprite = $LightSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func respawn():
	monitoring = true
	monitorable = true
	light_sprite.visible = true
	sprite.modulate = Color(1, 1, 1, 1)


func use():
	monitoring = false
	monitorable = false
	sprite.modulate = Color(0.5, 0.5, 0.5, 1)
	light_sprite.visible = false


func _on_SummoningArea_body_entered(body):
	if body.is_in_group("Player"):
		body.current_summoning_area = self


func _on_SummoningArea_body_exited(body):
	if body.is_in_group("Player"):
		body.current_summoning_area = null
