extends KinematicBody2D


# Movimento
export (int) var base_speed = 100
const ZERO = Vector2(0, 0)
var velocity

# Vida
signal health_changed
export (int) var max_health = 100
export (int) var knockback_percent = 10
var health

# Combate
export (int) var damage = 10
export (float) var attack_cooldown = 1
export (float) var hit_duration = 1	# @note funciona pq a animacao 'hit' dura 1 seg
export (PackedScene) var attack
const DISPLACEMENT = 17.625


# Inicializacao
func _ready():
	velocity = ZERO
	health = max_health
	$AttackTimer.wait_time = attack_cooldown

	# deixa o processamento pausado ate acabar de spawnar
	set_physics_process(false)
	$SpawnSound.play()
	$Sprite.set_animation('spawn')
	$Sprite.play()

# Game Loop
func _physics_process(delta):
	control(delta)
	move_and_slide(velocity)		# ps: colliders sao quadrados
	# position += velocity * delta	# movimentacao manual ignora colisoes

	# transicao instantanea, "assincrona"
	if $Sprite.get_animation() in ['idle', 'move']:
		if velocity.length() == 0:
			$Sprite.set_animation('idle')
		else:
			$Sprite.set_animation('move')

	# troca de lado
	if velocity.x < 0:
		$Sprite.flip_h = true
		$Weapon.scale.y = -1
	elif velocity.x > 0:
		$Sprite.flip_h = false
		$Weapon.scale.y = 1


# Aplicacao de dano
func update_health(delta, direction=null):
	health += min(delta, max_health - health)
	emit_signal('health_changed', health * 100 / max_health)
	if -delta * 100 / max_health >= knockback_percent:
		knockback(direction)
	if health <= 0 and not $Sprite.get_animation() == 'death':
		set_physics_process(false)
		$DeathSound.play()
		$Sprite.set_animation('death')
		$Sprite.play()

# Joga na direcao do parametro, pisca e desabilita colisao por um tempo
func knockback(direction=null):
	$Animator.play('hit', -1, 1/hit_duration)
	$HitSound.play()
	if direction != null:
		position += direction.normalized() * DISPLACEMENT * scale.x

# Ataque
func attack(direction):
	if $AttackTimer.is_stopped() and not $Sprite.get_animation() == 'death':
		var new_attack = attack.instance()
		$Weapon.set_rotation(direction.angle())
		$Weapon/AttackContainer.add_child(new_attack)
		new_attack.execute(damage, self.collision_mask)
		$AttackTimer.start()
		$ActionSound.play()
		$Sprite.set_animation('attack')
		$Sprite.play()

func control(delta):
	# update velocity
	pass

func die():
	pass


# Estados de animacao, transicao "sincrona"
func _on_Sprite_animation_finished():
	match $Sprite.get_animation():
		'spawn':	# reabilita processamento
			set_physics_process(true)
			$Sprite.set_animation('idle')

		'death':
			die()
			return

		'idle', 'move', 'attack':
			if velocity.length() == 0:	# idle se estiver parado
				$Sprite.set_animation('idle')
			else:	# move se estiver se movendo
				$Sprite.set_animation('move')

	$Sprite.play()
