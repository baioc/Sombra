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


# Inicializacao
func _ready():
	velocity = ZERO
	health = max_health
	$AttackTimer.wait_time = attack_cooldown

# Game Loop
func _physics_process(delta):
	control(delta)
	move_and_slide(velocity)


func lose_health(damage):
	health -= damage
	emit_signal('health_changed', health * 100 / max_health)

	if damage * 100 / max_health >= knockback_percent:
		knockback()

	if health <= 0:
		die()

# pisca e desabilita collider
func knockback():
	$Animator.play('hit', -1, 1/hit_duration)

func attack(direction):
	if $AttackTimer.is_stopped():
		var new_attack = attack.instance()
		$Weapon.rotation = direction.angle()
		$Weapon/AttackContainer.add_child(new_attack)
		new_attack.execute(damage)
		$AttackTimer.start()

func control(delta):	# update velocity
	pass

func die():
	pass
