extends Node

var replayer_scene = preload("res://Replayer.tscn")
var player_scene = preload("res://Player.tscn")

export(PackedScene) var next_level_scene

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var replayers: Node = $Replayers
onready var player = $Player
onready var summoning_areas = $SummoningAreas
onready var summoning_areas_left = summoning_areas.get_child_count()

onready var exit = $Exit

# Called when the node enters the scene tree for the first time.
func _ready():
	# Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	respawn(self)
	try_open_door()
	if next_level_scene == null:
		pass
		# next_level_scene = preload("res://World1.tscn")


func respawn(node: Node):
	if node == self:
		for child in replayers.get_children():
			child.queue_free()
		for child in node.get_children():
			respawn(child)
		summoning_areas_left = summoning_areas.get_child_count()
	elif !node.has_method("respawn"):
		for child in node.get_children():
			respawn(child)
	else:
		node.respawn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if Input.is_action_just_pressed("restart_game"):
#		get_tree().reload_current_scene()


func try_open_door():
	print_debug("summoning_areas_left", summoning_areas_left)
	if summoning_areas_left <= 0:
		exit.open_door()


func _on_Player_replayer_summoned(player):
	print_debug("world _on_Player_replayer_summoned")
	var replayer: KinematicBody2D = replayer_scene.instance()
	replayer.position = player.position
	replayer.inputQueueCapacity = 300 + 30 * replayers.get_child_count()
	player.connect("player_tick_processed", replayer, "_on_Player_player_tick_processed")
	replayers.add_child(replayer)
	summoning_areas_left -= 1
	try_open_door()



func _on_Player_player_tick_processed():
	for replayer in replayers.get_children():
		pass


func _on_Player_player_kill_finished():
	respawn(self)


func _on_Player_player_exit_finished():
	var next_level: Node = next_level_scene.instance()
	queue_free()
	get_parent().add_child(next_level)
	pass # Replace with function body.
