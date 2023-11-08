extends KinematicBody2D

export var move_speed := 100.0
export var life := 150
export var dead = false
export var _revive = false
var player: KinematicBody2D
var boss: KinematicBody2D
var motion
var attack = false
var num_audio
var audio_groan

onready var animation_player = $AnimationPlayer
var blood = preload("res://Assets/Scenes/Blood.tscn")

func _ready():
	randomize()
	player = get_tree().get_nodes_in_group("Player")[0]
	if get_tree().has_group("Boss"):
		boss = get_tree().get_nodes_in_group("Boss")[0]
	
func _process(delta):
	look_at(player.global_position)
	animations()
	
func _physics_process(delta):

	var direction = player.global_position - global_position

	if direction.length() < 1000 && !attack:
		motion = direction.normalized() * move_speed
	else:
		motion = Vector2()	
	
	move_and_slide(motion)

func animations():

	if motion != Vector2.ZERO && !dead && !_revive:
		animation_player.play("Move")
	elif motion == Vector2.ZERO && !attack && !dead && !_revive:
		animation_player.play("Idle")
	if attack && !dead:
		animation_player.play("Attack")
	if dead:
		animation_player.play("Dead")
		$CollisionShape2D.disabled = true
		$Timer.stop()
		set_process(false)
		set_physics_process(false)

func revivir():	
	$CollisionShape2D.disabled = false
	set_process(true)
	animation_player.play("Revive")
	dead = false
	life = 100
	$Timer.start(5)

func stop_anim():
	#Funcion para cambiar valores para coordinar las animacions del Zombie Boss
	boss.change_value()

func choose(array):
	array.shuffle()
	return array.front()

func change_num():
	match num_audio:
		1:
			audio_groan = preload("res://Assets/Sounds/Groan (1).wav")
			$Groan.set_stream(audio_groan)
		2:
			audio_groan = preload("res://Assets/Sounds/Groan (2).wav")
			$Groan.set_stream(audio_groan)
		3:
			audio_groan = preload("res://Assets/Sounds/Groan (3).wav")
			$Groan.set_stream(audio_groan)
		4:
			audio_groan = preload("res://Assets/Sounds/Groan (4).wav")
			$Groan.set_stream(audio_groan)
		5:
			audio_groan = preload("res://Assets/Sounds/Groan (5).wav")
			$Groan.set_stream(audio_groan)
		6:
			audio_groan = preload("res://Assets/Sounds/Groan (6).wav")
			$Groan.set_stream(audio_groan)

func _on_Attack_body_entered(body):
	if body.is_in_group("Player") && !dead:
		attack = true
		body.take_damage()

func _on_Attack_body_exited(body):
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

func _on_Timer_timeout():
	$Groan.playing = true
	$Timer.start(5)
	num_audio = choose([1, 2, 3, 4, 5, 6])
	change_num()
