extends "res://characters/Character.gd"


# Sinais
signal enemy_death

# Estados
enum STATE { IDLE, CHASE, FIGHT }
var state
var dir
var target

# Variaveis
export (float) var chase_speed = 85
export (float) var detect_range = 275
export (float) var attack_range = 70
export (float) var roam_delay = 2.5

const slow_ratio = 4	# deixa o inimigo mais lento enquanto luta


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
	emit_signal('enemy_death')
	queue_free()


func roam():
	velocity = dir.normalized() * base_speed

func chase(target):
	dir = target.position - position	# direcao do alvo
	velocity = dir.normalized() * chase_speed

func fight(target):
	dir = target.position - position
	attack(dir)
	velocity = dir.normalized() * chase_speed / slow_ratio


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
		if $AttackTimer.is_stopped():
			$AttackTimer.start()	# espera para atacar, nao seria preciso com animacao

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
