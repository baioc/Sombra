extends "res://character/Character.gd"


func control():
	velocity = ZERO
	if Input.is_action_pressed("ui_up"):
		velocity.y += -1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x += -1
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1

	velocity = velocity.normalized() * speed


func die():
	# @todo
	pass
