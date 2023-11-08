extends Area2D

var player: KinematicBody2D

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	
func _on_Next_Level_body_entered(body):
	#Llamamos la transicion para pasar al segundo nivel
	if body.is_in_group("Player") && player.active_shot_gun:
		Transition.init_transition("res://Assets/Scenes/Level 2.tscn")
	
