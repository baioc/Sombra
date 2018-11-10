extends "res://characters/Character.gd"


# Sinais
signal enemy_death

# Constantes
const slow_ratio = 4	# deixa o inimigo mais lento enquanto "luta"

# Estados
enum STATE { IDLE, CHASE, FIGHT }

# Configuraveis
export (float) var chase_speed = 85
export (float) var detect_range = 275
export (float) var attack_range = 70
export (float) var roam_delay = 2.5

# Variaveis
var state
var dir
var target


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
			chase(target)
		FIGHT:
			fight(target)
		IDLE:
			roam()

func die():
	# avisa os interessados
	emit_signal('enemy_death', self)
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
		if $DetectRange.overlaps_body(body):
			dir = ZERO	# fica parado depois do player levar knockback
		target = null
		state = IDLE
		$RoamTimer.start()

# Em range para ataque
func _on_AttackRange_body_entered(body):
	if target == null:
		target = body
	if body == target:
		state = FIGHT
		if not $GrowlSound.playing:
			$GrowlSound.play()
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
