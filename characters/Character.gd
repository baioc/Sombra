extends KinematicBody2D


export (int) var speed = 100
const ZERO = Vector2(0, 0)
var velocity = ZERO

export (int) var max_health = 100
signal health_changed
var health = max_health


func _ready():
	emit_signal('health_changed', health)

func _physics_process(delta):
	if health > 0:
		control(delta)
	else:
		die()

	move_and_slide(velocity)


func control(delta):
	# update velocity
	pass

func die():
	pass

func _on_Character_hit(damage):
	health -= damage
	emit_signal('health_changed', health)
