extends KinematicBody2D


export (int) var max_health = 100
export (int) var speed = 100

const ZERO = Vector2(0, 0)

var health = max_health
var velocity = ZERO


func _ready():
	_physics_process(true);
	pass

func _physics_process(delta):
	if health > 0:
		control(delta)
	else:
		die()

	move_and_slide(velocity)


func control(delta):
	pass

func die():
	pass
