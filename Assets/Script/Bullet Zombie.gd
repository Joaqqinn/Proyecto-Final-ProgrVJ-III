extends RigidBody2D

func _ready():
	$AnimationPlayer.play("Shoot")

func _on_Bullet_body_entered(body):
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
