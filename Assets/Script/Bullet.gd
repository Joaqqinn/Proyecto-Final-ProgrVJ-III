extends RigidBody2D

var blood = preload("res://Assets/Scenes/Blood.tscn")

func _on_Bullet_body_entered(body):
	if !body.is_in_group("Bullet"):
		queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
