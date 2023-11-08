extends KinematicBody2D

enum {
	IDLE,
	TAKE,
	SHOT,
	SHOT2,
	FIRE,
	ATTACK,
	RIGHT,
	LEFT,
	REVIVE
}

var current_state = IDLE
export var move_speed := 130.0
export var life := 500
export var bullet_speed = 1000
export var fire_rate = 0
export var can_fire = true
export var revive = false
export var stop_anim = false
var player: KinematicBody2D
var motion
var attack = false
var dead = false
var shoot = true
var num_audio
var audio_groan

signal the_end

onready var animation_player = $AnimationPlayer
onready var firePoint = $FirePoint
onready var firePoint2 = $FirePoint2
var arm = preload("res://Assets/Scenes/ArmZombie.tscn")
var claws = preload("res://Assets/Scenes/ClawsZombie.tscn")
var blood = preload("res://Assets/Scenes/Blood.tscn")

func _ready():
	randomize()
	player = get_tree().get_nodes_in_group("Player")[0]

func _process(delta):
	look_at(player.global_position)
	animations()
	#Si se interrumpe la animacion Revive escondemos la imagen
	if current_state != REVIVE:
		$Burst.visible = false
		
	match current_state:
		IDLE:
			if !dead:
				animation_player.play("Idle")
		TAKE:
			if !dead:
				move()
		SHOT:
			if shoot && !dead: 
				animation_player.play("Shot")
			else:
				$Timer.emit_signal("timeout")
			if shoot && can_fire && !dead:
				fire()
		SHOT2:
			if shoot && !dead:
				animation_player.play("Shot 2")
			else:
				$Timer.emit_signal("timeout")
			if shoot && can_fire && !dead:
				fire()
		FIRE:
			if attack:
				animation_player.play("Fire")
			else:
				$Fire.visible = false
				$Timer.emit_signal("timeout")
		ATTACK:
			if attack:
				$Fire.visible = false
				animation_player.play("Attack")
			else:
				$Timer.emit_signal("timeout")
		RIGHT:
			if !dead:
				move()
		LEFT:
			if !dead:
				move()
		REVIVE:
			if get_tree().has_group("Revive"):
				for i in get_tree().get_nodes_in_group("Revive").size():
					if get_tree().get_nodes_in_group("Revive")[i]._revive == true && !stop_anim && !dead:
						animation_player.play("Revive")
						life = 500

func choose(array):
	array.shuffle()
	return array.front()

func revivir():
	#La llamamos desde la animacion para coordinar los tiempos de ejecucion
	for i in get_tree().get_nodes_in_group("Revive").size():
		if get_tree().get_nodes_in_group("Revive")[i]._revive == true:
			get_tree().get_nodes_in_group("Revive")[i].revivir()

func change_value():
	#Detenemos la animacion
	stop_anim = false

func move():
	var direction = player.global_position - global_position
	
	match current_state:
		1:
			direction = player.global_position - global_position
			animation_player.play("Move")
		6:
			direction = $Right.global_position - global_position
			animation_player.play("Move")
		7:
			direction = $Left.global_position - global_position
			animation_player.play("Move")
		_:
			direction = Vector2()
			$Timer.emit_signal("timeout")

	motion = direction.normalized() * move_speed
	
	move_and_slide(motion)	

func fire():
	can_fire = false
	var bullet_instance
	if current_state == 2:
		bullet_instance = arm.instance()
		bullet_instance.position = firePoint.get_global_position()
	if current_state == 3:
		bullet_instance = claws.instance()
		bullet_instance.position = firePoint2.get_global_position()
	bullet_instance.rotation_degrees = rotation_degrees
	bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation))
	get_tree().get_root().call_deferred("add_child", bullet_instance)
	#Ratio de disparo
	fire_rate = 3.0
	yield(get_tree().create_timer(fire_rate), "timeout")
	animation_player.play("Shoot")

func animations():
	if dead:
		animation_player.play("Dead")
		$CollisionShape2D.disabled = true
		$Timer2.stop()
		set_process(false)
		set_physics_process(false)

func change_num():
	match num_audio:
		1:
			audio_groan = preload("res://Assets/Sounds/Boss Groan (1).wav")
			$Groan.set_stream(audio_groan)
		2:
			audio_groan = preload("res://Assets/Sounds/Boss Groan (2).wav")
			$Groan.set_stream(audio_groan)
		3:
			audio_groan = preload("res://Assets/Sounds/Boss Groan (3).wav")
			$Groan.set_stream(audio_groan)
#Si muere el Boss eliminamos a todos los Zombies
func kill_all():
	if dead:
		if get_tree().has_group("Revive"):
				for i in get_tree().get_nodes_in_group("Revive").size():
					get_tree().get_nodes_in_group("Revive")[i].dead = true

#IDLE, TAKE, SHOT, SHOT2, RIGHT, LEFT, REVIVE
func _on_Timer_timeout():
	if !dead:
		$Timer.wait_time = choose([5, 5.5, 6])
		if attack:
			current_state = choose([ATTACK, FIRE])
		else:
			current_state = choose([IDLE, TAKE, SHOT, SHOT2, RIGHT, LEFT, REVIVE])
	
func _on_Attack_body_entered(body):
	if (body.is_in_group("Player") && !dead):
		attack = true
		$Burst.visible = false
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
		blood_instance.global_position = $Sprite.global_position
		blood_instance.rotation = global_position.angle_to_point(player.global_position)
		$ImpactBullet.playing = true
		#Restar vida
		if life != 0:
			life -= 25
		if life == 0:
			dead = true

func _on_Shot_body_entered(body):
	if (body.is_in_group("Player") && !dead):
		shoot = true
		#print("DISPARAR")

func _on_Shot_body_exited(body):
	if body.is_in_group("Player"):
		shoot = false
		#print("NO DISPARAR")

func _on_Timer2_timeout():
	$Groan.playing = true
	$Timer2.start(choose([5, 6, 7]))
	num_audio = choose([1, 2, 3, 4, 5, 6])
	change_num()

func _on_PlayerWin_body_entered(body):
	if (body.is_in_group("Player") && dead):
		emit_signal("the_end")
		print("GANASTE")
