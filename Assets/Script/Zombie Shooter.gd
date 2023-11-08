extends KinematicBody2D

export var bullet_speed = 1000
export var move_speed = 350
export var fire_rate = 0
export var can_fire = true
export var life := 250
export var dead = false
export var _revive = false

var player: KinematicBody2D
var boss: KinematicBody2D
var random = RandomNumberGenerator.new()
var motion
var shoot = false
var attack = false
var evade : int
var evade_right_position
var evade_left_position
var direction
var select_direction

onready var animation_player = $AnimationPlayer
onready var firePoint = $FirePoint
onready var evade_right = $EvadeRight
onready var evade_left = $EvadeLeft

var bullet = preload("res://Assets/Scenes/Bullet Zombie.tscn")
var blood = preload("res://Assets/Scenes/Blood.tscn")

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	if get_tree().has_group("Boss"):
		boss = get_tree().get_nodes_in_group("Boss")[0]
	random.randomize()

func _process(delta):
	look_at(player.global_position)
	animations()
	if shoot && can_fire && !dead && !_revive:
		fire()

func _physics_process(delta):
	if evade == 1:
		if select_direction == 1:
			direction = evade_right_position - global_position
		else:
			direction = evade_left_position - global_position

		if direction.length() > 10:
			$Sprite.visible = false
			motion = direction.normalized() * move_speed
		else:
			$Sprite.visible = true
			motion = Vector2()
			
		move_and_slide(motion)

func fire():
	can_fire = false
	var bullet_instance = bullet.instance()
	bullet_instance.position = firePoint.get_global_position()
	bullet_instance.rotation_degrees = rotation_degrees
	bullet_instance.apply_impulse(Vector2(), Vector2(bullet_speed, 0).rotated(rotation))
	get_tree().get_root().call_deferred("add_child", bullet_instance)
	$SoundShoot.playing = true
	#Ratio de disparo
	fire_rate = 3.0
	yield(get_tree().create_timer(fire_rate), "timeout")
	if !_revive:
		animation_player.play("Shoot")

func animations():
	if attack && !dead:
		animation_player.play("Attack")
	if !attack && !dead && !_revive:
		pass
	if dead:
		$Sprite.visible = true
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

func _on_Shoot_body_entered(body):
	if body.is_in_group("Player") && !dead:
		shoot = true

func _on_Shoot_body_exited(body):
	if body.is_in_group("Player"):
		shoot = false

func _on_Evade_body_entered(body):
	if body.is_in_group("Bullet"):
		evade_right_position = evade_right.get_global_position()
		evade_left_position = evade_left.get_global_position()
		evade = random.randi_range(1, 2)
		select_direction = random.randi_range(1, 2)
		if evade == 1:
			$SoundEvade.playing = true

func _on_Attack_body_entered(body):
	if body.is_in_group("Player") && !dead:
		can_fire = false
		attack = true
		body.take_damage()

func _on_Attack_body_exited(body):
	if body.is_in_group("Player") && !dead:
		can_fire = true
		attack = false
		body.stop_damage()

func _on_Life_body_entered(body):
	if body.is_in_group("Bullet") && !dead:
		#Sangre
		var blood_instance = blood.instance()
		blood_instance.texture = preload("res://Assets/Sprite/Extras/blood green.png")
		get_tree().current_scene.add_child(blood_instance)
		blood_instance.global_position = global_position
		blood_instance.rotation = global_position.angle_to_point(player.global_position)
		$ImpactBullet.playing = true
		#Restar vida
		if life != 0:
			life -= 25
		if life == 0:
			dead = true
