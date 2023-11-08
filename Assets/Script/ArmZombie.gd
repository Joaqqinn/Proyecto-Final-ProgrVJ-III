extends RigidBody2D

func _on_ArmZombie_body_entered(body):
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
