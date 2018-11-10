extends Control

export (PackedScene) var level

func _on_StartButton_pressed():
	get_tree().change_scene_to(level)

func _on_QuitButton_pressed():
	get_tree().quit()

func _ready():
	$MarginContainer/VBoxContainer/HBoxContainer/PointLabel.set_text(str(Global.high_score))

func _on_BackTrack_finished():
	$BackTrack.play()
