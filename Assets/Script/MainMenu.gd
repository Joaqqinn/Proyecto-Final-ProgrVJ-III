extends Control
#Llamamos la transicion al primer nivel
func _on_Jugar_pressed():
	Transition.init_transition("res://Assets/Scenes/World.tscn")
#Salimos del juego
func _on_Salir_pressed():
	get_tree().quit()
