extends "res://characters/Character.gd"


# Estados
enum STATE { IDLE, CHASE, FIGHT }
var state
var dir
var target

# Variaveis
export (float) var chase_speed = 100
export (float) var detect_range = 300.0
export (float) var attack_range = 80
export (float) var roam_delay = 2.5


# Inicializacao
func _ready():
	randomize()	# garante numeros aleatorios para funcoes random

	# Estado inicial
	dir = ZERO
	target = null
	state = IDLE
	$RoamTimer.wait_time = roam_delay
	$RoamTimer.start()

	# Zona de visao
	var detection_zone = CircleShape2D.new()
	detection_zone.radius = detect_range
	$DetectRange/Area.shape = detection_zone

	# Range de ataque
	var fight_zone = CircleShape2D.new()
	fight_zone.radius = attack_range
	$AttackRange/Area.shape = fight_zone


# @debug do hp do inimigo
func lose_health(damage):
	.lose_health(damage)
	print(health, " HP do inimigo, pora")
	# @todo jogar o inimigo para tras de vdd na funcao knockback()

# Maquina de estados em loop
func control(delta):
	match state:
		CHASE:
			$Sprite.modulate = Color8(255, 128, 0)	# @debug enemy state
			chase(target)
		FIGHT:
			$Sprite.modulate = Color8(255, 0, 0)
			fight(target)
		IDLE:
			$Sprite.modulate = Color8(0, 0, 0)
			roam()

func die():
	# @todo
	queue_free()


func roam():
	velocity = dir.normalized() * base_speed

func chase(target):
	dir = target.position - position	# direcao do alvo
	velocity = dir.normalized() * chase_speed

func fight(target):
	dir = target.position - position
	attack(dir)


# Deteccao de alvo
func _on_DetectRange_body_entered(body):
	if target == null:
		target = body
		state = CHASE

# Perdeu o alvo
func _on_DetectRange_body_exited(body):
	if body == target:
		target = null
		state = IDLE
		$RoamTimer.start()

# Em range para ataque
func _on_AttackRange_body_entered(body):
	if target == null:
		target = body
	if body == target:
		state = FIGHT

# Fora da range
func _on_AttackRange_body_exited(body):
	if body == target:
		state = CHASE

# Troca a direcao aleatoriamente
func _on_RoamTimer_timeout():
	if state == IDLE:
		dir.x = rand_range(-1, 1)
		dir.y = rand_range(-1, 1)
	else:
		$RoamTimer.stop()
