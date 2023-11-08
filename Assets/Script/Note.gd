extends Area2D

func _on_CanvasLayer_note():
	if !$Sprite2.visible:
		$Sprite2.visible = true
	else:
		$Sprite2.visible = false

func _on_CanvasLayer_note1():
	if !$Sprite3.visible:
		$Sprite3.visible = true
		$Sprite1.visible = false
	else:
		$Sprite3.visible = false
