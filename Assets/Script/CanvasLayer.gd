extends CanvasLayer

var player: KinematicBody2D
var read_note = false
var read_note1 = false

signal note
signal note1

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	$Background.playing = true
	
func _process(delta):
	if(Input.is_action_just_pressed("F")):
		if read_note:
			emit_signal("note")
		if read_note1:
			player.active_shot_gun = true
			$VFlowContainer/Shot_Gun.visible = true
			emit_signal("note1")	
	show_charger()
#Mostramos la cantidad de balas en pantalla
func show_charger():
	if player.hand_gun:
		$HFlowContainer/Bullets.text = str(player.charger_hand_gun) + "/15"
	if player.rifle:
		$HFlowContainer/Bullets.text = str(player.charger_rifle) + "/30"
	if player.shot_gun:
		$HFlowContainer/Bullets.text = str(player.charger_shot_gun) + "/3"

func _on_Note_body_entered(body):
	if body.is_in_group("Player"):
		read_note = true
		$PressF.visible = true

func _on_Note_body_exited(body):
	if body.is_in_group("Player"):
		read_note = false
		$PressF.visible = false

func _on_Note1_body_entered(body):
	if body.is_in_group("Player"):
		read_note1 = true
		$PressF.visible = true

func _on_Note1_body_exited(body):
	if body.is_in_group("Player"):
		read_note1 = false
		$PressF.visible = false

func _on_Rifle_rifle():
	$VFlowContainer/Rifle.visible = true

func _on_Player_menu_dead():
	get_tree().paused = true
	$MenuDead/Popup2.visible = true

func _on_Button2_pressed():
	get_tree().reload_current_scene()
	get_tree().paused = false

func _on_Button1_pressed():
	get_tree().quit()

func _on_Zombie_Boss_the_end():
	$TheEnd.visible = true
	$Timer.start(5)

func _on_Timer_timeout():
	get_tree().quit()
