extends KinematicBody2D

export var moveSpeed = 160
export var bullet_speed = 1000
export var can_fire = true
export var change_weapon = false
export var reload = false
export var fire_rate = 0
export var tiempo = 0
export var tiempo1 = 0
export var hand_gun = true
export var rifle = false
export var shot_gun = false
export var charger_hand_gun = 15
export var charger_rifle = 30
export var charger_shot_gun = 3
export var active_rifle = false
export var active_shot_gun = false

var motion
var state_machine
var receive_attack = false
var num_audio
var audio_receive_attack

signal shot
signal menu_dead

onready var shotFlash = $SpritePlayer/ShotFlash
onready var shotFlash2 = $SpritePlayer/ShotFlash2
onready var firePointGun = $SpritePlayer/FirePointGun
onready var firePointRifle = $SpritePlayer/FirePointRifle
onready var spriteShotFlash = $SpritePlayer/SpriteShotFlash
onready var spriteShotFlash2 = $SpritePlayer/SpriteShotFlash2

var bullet = preload("res://Assets/Scenes/Bullet.tscn")
var bullet_casing = preload("res://Assets/Scenes/Bullet Casing.tscn")

func _ready():
	randomize()

func _process(delta):
	state_machine = $SpritePlayer/AnimationTree.get("parameters/playback")
	#Player mira hacia el mouse
	look_at(get_global_mouse_position())
	#Cuando apretamos Boton izquierdo del mouse disparamos
	if(Input.is_action_just_pressed("fire") && !change_weapon && can_fire && !reload):
		fire()
		#Emitimos la señal para mover la pantalla
		emit_signal("shot")
		#Animaciones de armas
		if hand_gun:
			shotFlash.play("ShotFlash")
			shotFlash2.play("ShotFlash2")
		else:
			shotFlash.play("ShotFlash 2")
			shotFlash2.play("ShotFlash2 2")
	#Cambio de armas
	change_weapons()
	#Animaciones
	animations()
	#Gestion de Vida
	control_life()
	#Cargadores de Armas
	reloading_weapons()
	
	

func _physics_process(delta):
	motion = Vector2()
	#Movimiento
	if Input.is_action_pressed("up"):
		motion.y -= 1
	if Input.is_action_pressed("down"):
		motion.y += 1
	if Input.is_action_pressed("right"):
		motion.x += 1
	if Input.is_action_pressed("left"):
		motion.x -= 1
		
	motion = motion.normalized()
	motion = move_and_slide(motion * moveSpeed)
	

func animations():
	#Gun
	if hand_gun:
		if motion != Vector2.ZERO:
			state_machine.travel("Gun Move")
		else:
			state_machine.travel("Gun Idle")
		if(Input.is_action_just_pressed("fire") && !reload):
			state_machine.travel("Gun Shoot")
		if(Input.is_action_just_pressed("Reload") && charger_hand_gun != 15):
			$HandGunReload.playing = true
			state_machine.travel("Gun Reload")
			
	#Rifle
	if rifle && active_rifle:
		if motion != Vector2.ZERO:
			state_machine.travel("Rifle Move")
		else:
			state_machine.travel("Rifle Idle")
		if(Input.is_action_just_pressed("fire") && !reload):
			state_machine.travel("Rifle Shoot")
		if(Input.is_action_just_pressed("Reload") && charger_rifle != 30):
			$RifleReload.playing = true
			state_machine.travel("Rifle Reload")
	#ShotGun
	if shot_gun && active_shot_gun:
		if motion != Vector2.ZERO:
			state_machine.travel("ShotGun Move")
		else:
			state_machine.travel("ShotGun Idle")
		if(Input.is_action_just_pressed("fire") && !reload):
			state_machine.travel("ShotGun Shoot")
		if(Input.is_action_just_pressed("Reload") && charger_shot_gun != 3):
			$HandGunReload.playing = true
			state_machine.travel("ShotGun Reload")

func fire():
	#Disparo
	#Pistola
	if hand_gun:
		var bullet_instance = bullet.instance()
		bullet_instance.position = firePointGun.get_global_position()
		bullet_instance.rotation_degrees = rotation_degrees
		bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation))
		get_tree().get_root().call_deferred("add_child", bullet_instance)
		$HandGunShoot.playing = true
		#Casquillo Bala
		var bullet_casing_instance = bullet_casing.instance()
		get_tree().current_scene.add_child(bullet_casing_instance)
		bullet_casing_instance.global_position = $SpritePlayer/FirePointGun.global_position
		bullet_casing_instance.rotation = global_position.angle_to_point($SpritePlayer/FirePointGun.global_position)
		#Modificamos posicion animaciones
		spriteShotFlash.position = firePointGun.position
		spriteShotFlash2.position = firePointGun.position
		#Restamos una bala del cargador
		charger_hand_gun -= 1
		#Ratio de disparo
		fire_rate = 0.3
		can_fire = false
		yield(get_tree().create_timer(fire_rate), "timeout")
		can_fire = true
	#Rifle
	if rifle && active_rifle:
		var bullet_instance = bullet.instance()
		bullet_instance.position = firePointRifle.get_global_position()
		bullet_instance.rotation_degrees = rotation_degrees
		bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation))
		get_tree().get_root().call_deferred("add_child", bullet_instance)
		$RifleShoot.playing = true
		#Casquillo Bala
		var bullet_casing_instance = bullet_casing.instance()
		get_tree().current_scene.add_child(bullet_casing_instance)
		bullet_casing_instance.global_position = $SpritePlayer/FirePointGun.global_position
		bullet_casing_instance.rotation = global_position.angle_to_point($SpritePlayer/FirePointGun.global_position)
		#Modificamos posicion animaciones
		spriteShotFlash.position = firePointRifle.position
		spriteShotFlash2.position = firePointRifle.position
		#Restamos una bala del cargador
		charger_rifle -= 1
		#Ratio de disparo
		fire_rate = 0.1
		can_fire = false
		yield(get_tree().create_timer(fire_rate), "timeout")
		can_fire = true
	#Escopeta, instanciamos 3 balas
	if shot_gun && active_shot_gun:
		var bullet_instance = bullet.instance()
		bullet_instance.position = firePointGun.get_global_position()
		bullet_instance.rotation_degrees = rotation_degrees
		bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed, -100).rotated(rotation))
		get_tree().get_root().call_deferred("add_child", bullet_instance)
		var bullet_instance1 = bullet.instance()
		bullet_instance1.position = firePointGun.get_global_position()
		bullet_instance1.rotation_degrees = rotation_degrees
		bullet_instance1.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation))
		get_tree().get_root().call_deferred("add_child", bullet_instance1)
		var bullet_instance2 = bullet.instance()
		bullet_instance2.position = firePointGun.get_global_position()
		bullet_instance2.rotation_degrees = rotation_degrees
		bullet_instance2.apply_impulse(Vector2(), Vector2(bullet_speed, 100).rotated(rotation))
		get_tree().get_root().call_deferred("add_child", bullet_instance2)
		$ShotGunShoot.playing = true
		#Casquillo Bala
		var bullet_casing_instance = bullet_casing.instance()
		get_tree().current_scene.add_child(bullet_casing_instance)
		bullet_casing_instance.global_position = $SpritePlayer/FirePointGun.global_position
		bullet_casing_instance.rotation = global_position.angle_to_point($SpritePlayer/FirePointGun.global_position)
		#Modificamos posicion animaciones
		spriteShotFlash.position = firePointRifle.position
		spriteShotFlash2.position = firePointRifle.position
		#Restamos una bala del cargador
		charger_shot_gun -= 1
		#Ratio de disparo
		fire_rate = 0.5
		can_fire = false
		yield(get_tree().create_timer(fire_rate), "timeout")
		can_fire = true

func change_weapons():
	#Arma numero 1
	if(Input.is_key_pressed(KEY_1) || Input.is_key_pressed(KEY_KP_1)):
		if charger_hand_gun != 0:
			reload = false
		hand_gun = true
		rifle = false
		shot_gun = false
	#Arma numero 2
	if((Input.is_key_pressed(KEY_2) || Input.is_key_pressed(KEY_KP_2)) && active_rifle):
		if charger_rifle != 0:
			reload = false
		hand_gun = false
		rifle = true
		shot_gun = false
	#Arma numero 3
	if((Input.is_key_pressed(KEY_3) || Input.is_key_pressed(KEY_KP_3)) && active_shot_gun):
		if charger_shot_gun != 0:
			reload = false
		hand_gun = false
		rifle = false
		shot_gun = true

func reloading_weapons():
	#Bloqueamos el disparo cuando no tenemos balas
	if hand_gun && charger_hand_gun == 0:
		reload = true
	if rifle && charger_rifle == 0:
		reload = true
	if shot_gun && charger_shot_gun == 0: 
		reload = true
		
func control_life():
	if receive_attack:
		#Restar vida
		tiempo = 0.5
		yield(get_tree().create_timer(tiempo), "timeout")
		$SpritePlayer/Light2D.scale.x -= 0.003
		if $SpritePlayer/Light2D.scale.x <= 0.01:
			emit_signal("menu_dead")

func take_damage():
	#Recibir daño
	receive_attack = true
	$Timer.start(1.5)
	num_audio = choose([1, 2, 3, 4, 5, 6, 7])
	change_num()

func stop_damage():
	#Dejar de recibir daño
	receive_attack = false
	$Timer.stop()

func choose(array):
	array.shuffle()
	return array.front()

func change_num():
	match num_audio:
		1:
			audio_receive_attack = preload("res://Assets/Sounds/Receive Attack (1).wav")
			$ReceiveAttack.set_stream(audio_receive_attack)
		2:
			audio_receive_attack = preload("res://Assets/Sounds/Receive Attack (2).wav")
			$ReceiveAttack.set_stream(audio_receive_attack)
		3:
			audio_receive_attack = preload("res://Assets/Sounds/Receive Attack (3).wav")
			$ReceiveAttack.set_stream(audio_receive_attack)
		4:
			audio_receive_attack = preload("res://Assets/Sounds/Receive Attack (4).wav")
			$ReceiveAttack.set_stream(audio_receive_attack)
		5:
			audio_receive_attack = preload("res://Assets/Sounds/Receive Attack (5).wav")
			$ReceiveAttack.set_stream(audio_receive_attack)
		6:
			audio_receive_attack = preload("res://Assets/Sounds/Receive Attack (6).wav")
			$ReceiveAttack.set_stream(audio_receive_attack)
		7:
			audio_receive_attack = preload("res://Assets/Sounds/Receive Attack (7).wav")
			$ReceiveAttack.set_stream(audio_receive_attack)

func _on_Life_body_entered(body):
	if body.is_in_group("Bullet Zombie"):
		$SpritePlayer/Light2D.scale.x -= 0.09
		$ImpactBulletZombie.playing = true
	if body.is_in_group("Bullet Zombie1"):
		$SpritePlayer/Light2D.scale.x -= 0.09
		$ImpactBulletZombie1.playing = true

func _on_Timer_timeout():
	$ReceiveAttack.playing = true
