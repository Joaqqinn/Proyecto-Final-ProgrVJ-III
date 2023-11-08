extends CanvasLayer

var scene 

func init_transition(_root):
	if _root != "":
		$AnimationPlayer.play("Init")
		#Definimos la ruta de la escena
		scene = _root

#Metodo para llamar a la escena desde la animacion
func change_scene():
	get_tree().change_scene(scene)
