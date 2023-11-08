extends Area2D

var player: KinematicBody2D

signal rifle

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	
func _on_Rifle_body_entered(body):
	if body.is_in_group("Player"):
		$Sprite.visible = false
		emit_signal("rifle")
		player.active_rifle = true
