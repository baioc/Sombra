extends KinematicBody2D


# Movimento
export (int) var base_speed = 100
const ZERO = Vector2(0, 0)
var velocity

# Vida
export (int) var max_health = 100
export (int) var knockback_percent = 10
signal health_changed
var health

# Combate
export (float) var hit_duration = 1	# @note funciona pq a animacao 'hit' dura 1 seg
export (int) var damage = 10
export (float) var attack_cooldown = 2
export (PackedScene) var attack
const DISPLACEMENT = 16


# Inicializacao
func _ready():
	velocity = ZERO
	health = max_health
	$AttackTimer.wait_time = attack_cooldown

# Game Loop
func _physics_process(delta):
	control(delta)
	move_and_slide(velocity)


# Aplicacao de dano
func take_hit(damage, attack_direction=null):
	if $Animator.current_animation == 'hit':
		return

	health -= damage
	emit_signal('health_changed', health * 100 / max_health)

	if damage * 100 / max_health >= knockback_percent:
		knockback(attack_direction)

	if health <= 0:
		die()


# Joga na direcao do parametro, pisca e desabilita colisao por um tempo
func knockback(direction=null):
	$Animator.play('hit', -1, 1/hit_duration)
	$HitSound.play()
	if direction != null:
		position += direction.normalized() * DISPLACEMENT * scale.x

# Ataque
func attack(direction):
	if $AttackTimer.is_stopped():
		var new_attack = attack.instance()
		$Weapon.rotation = direction.angle()
		$Weapon/AttackContainer.add_child(new_attack)
		new_attack.execute(damage, collision_mask)
		$AttackTimer.start()
		$ActionSound.play()

func control(delta):
	# update velocity
	pass

func die():
	pass
