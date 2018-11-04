extends "res://characters/Character.gd"


enum STATE { IDLE, CHASE, FIGHT }

export (float) var detect_range = 300.0
export (float) var attack_range = 70.0
export (float) var roam_delay = 2.0

var state = IDLE
var target = null
var dir = ZERO


func _ready():
	randomize()
	$RoamTimer.wait_time = roam_delay
	$RoamTimer.start()

	var detection_zone = CircleShape2D.new()
	detection_zone.radius = detect_range
	$DetectRange/Area.shape = detection_zone

	var fight_zone = CircleShape2D.new()
	fight_zone.radius = attack_range
	$AttackRange/Area.shape = fight_zone


func control(delta):
	match state:
		CHASE:
			chase(target)
		FIGHT:
			fight(target)
		IDLE:
			roam()

func die():
	# @todo
	pass

func roam():
	velocity = dir.normalized() * speed

func chase(target):
	var d = target.position - position
	velocity = d.normalized() * speed

func fight(target):
	# @todo
	pass


func _on_DetectRange_body_entered(body):
	if target == null:
		target = body
		state = CHASE
		$Sprite.set_modulate(Color8(255, 128, 0))	# @debug enemy state

func _on_DetectRange_body_exited(body):
	if body == target:
		target = null
		state = IDLE
		dir = ZERO
		$RoamTimer.start()
		$Sprite.set_modulate(Color8(0, 0, 0))

func _on_AttackRange_body_entered(body):
	if target == null:
		target = body
	if body == target:
		state = FIGHT
		$Sprite.set_modulate(Color8(255, 0, 0))

func _on_AttackRange_body_exited(body):
	if body == target:
		state = CHASE
		$Sprite.set_modulate(Color8(255, 128, 0))

func _on_RoamTimer_timeout():
	dir.x = rand_range(-1, 1)
	dir.y = rand_range(-1, 1)

	if state != IDLE:
		$RoamTimer.stop()
