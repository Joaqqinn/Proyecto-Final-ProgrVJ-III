extends RigidBody2D

export var move_speed := 60.0
export var life := 150
export var _revive = false
export var dead = false
var player: KinematicBody2D
var boss: KinematicBody2D
var rotation_speed = 2.0
var attack = false
var speed_attack = 50
var time_out = false

onready var animation_player = $AnimationPlayer

var blood = preload("res://Assets/Scenes/Blood.tscn")

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	if get_tree().has_group("Boss"):
		boss = get_tree().get_nodes_in_group("Boss")[0]
	$Timer.start(5)
	
func _process(delta):
	animations()
		
func _physics_process(delta):
	rotate_to_target(player, delta)
	
	var direction = player.global_position - global_position

	if direction.length() < 1000 && time_out:
		$Impulse.playing = true
		apply_impulse(Vector2(), Vector2(player.global_position - global_position) * speed_attack)
		$Sprite/Blood.visible = true
		time_out = false
		$Timer.start(5)
	
func rotate_to_target(target, delta):
	var direction = (target.global_position - global_position)
	var angleTo = transform.x.angle_to(direction)
	rotate(sign(angleTo) * min(delta * rotation_speed, abs(angleTo)))

func animations():
	if attack && !dead:
		animation_player.play("Attack")
	if !attack && !dead && !_revive:
		animation_player.play("Idle")
	if dead:
		animation_player.play("Dead")
		$CollisionShape2D.disabled = true
		set_process(false)
		set_physics_process(false)
		
func revivir():	
	$CollisionShape2D.disabled = false
	set_process(true)
	animation_player.play("Revive")
	dead = false
	life = 100

func stop_anim():
	#Funcion para cambiar valores para coordinar las animacions del Zombie Boss
	boss.change_value()

func _on_Timer_timeout():
	time_out = true

func _on_Area2D_body_entered(body):
	if body.is_in_group("Player") && !dead:
		attack = true
		$Sprite/Blood.visible = false
		body.take_damage()

func _on_Area2D_body_exited(body):
	if body.is_in_group("Player"):
		attack = false
		body.stop_damage()

func _on_Life_body_entered(body):
	if body.is_in_group("Bullet") && !dead:
		#Sangre
		var blood_instance = blood.instance()
		get_tree().current_scene.add_child(blood_instance)
		blood_instance.global_position = global_position
		blood_instance.rotation = global_position.angle_to_point(player.global_position)
		$ImpactBullet.playing = true
		#Restar vida
		if life != 0:
			life -= 25
		if life == 0:
			dead = true
