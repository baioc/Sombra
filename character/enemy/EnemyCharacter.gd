extends "res://character/Character.gd"


export (float) var detect_range = 150.0
export (float) var attack_range = 70.0

var state = 'IDLE'
var target = null
var dir = ZERO


func _ready():
	randomize()

	var detection_zone = CircleShape2D.new()
	detection_zone.radius = detect_range
	$DetectRange/Area.shape = detection_zone

	var fight_zone = CircleShape2D.new()
	fight_zone.radius = attack_range
	$AttackRange/Area.shape = fight_zone


func control():
	match state:
		'CHASE':
			chase(target)
		'FIGHT':
			fight(target)
		'IDLE':
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


# @todo collision masks
func _on_DetectRange_body_entered(body):
	if not target and body != self:
		target = body
		state = 'CHASE'

func _on_DetectRange_body_exited(body):
	if body == target:
		target = null
		state = 'IDLE'
		dir = ZERO
		$RoamTimer.start()

func _on_AttackRange_body_entered(body):
	if not target and body != self:
		target = body
	if body == target:
		state = 'FIGHT'

func _on_AttackRange_body_exited(body):
	if body == target:
		state = 'CHASE'

func _on_RoamTimer_timeout():
	dir.x = rand_range(-1, 1)
	dir.y = rand_range(-1, 1)

	if state != 'IDLE':
		$RoamTimer.stop()
