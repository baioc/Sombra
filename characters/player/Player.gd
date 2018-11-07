extends "res://characters/Character.gd"


# Movimento do personagem
export (int) var dash_speed = 400
var direction = Vector2(1, 0)

# Energia
export (int) var max_energy = 100
export (int) var dash_cost = 25
export (int) var energy_regen = 5
signal energy_changed	# @todo remover GUI da Scene do Player talvez conserte o bug do crescimento
var energy

# Timing
export (float) var dash_delay = 0.5
export (float) var energy_regen_delay = 0.75


# Inicializacao
func _ready():
	energy = max_energy
	$Camera.current = true
	$DashTimer.wait_time = dash_delay
	$RegenTimer.wait_time = energy_regen_delay


func lose_health(damage):
	.lose_health(damage)			# chama o metodo herdado
	print("Player HP: ", health)	# @debug hp
	# @fixme multiplos ataques simultaneos causam dano varias vezes

# Loop
func control(delta):
	get_input()
	update_velocity()

func die():
	# @todo
	print("* GAME OVER *")
	queue_free()


func get_input():
	# @debug da barra de vida
	if Input.is_action_just_pressed('test_hp'):
		lose_health(max_health * knockback_percent / 100)

	# Atack
	if Input.is_action_just_pressed('attack'):
		attack(direction)

	# Movimento
	if $DashTimer.is_stopped():
		velocity = ZERO

		if Input.is_action_pressed("ui_right"):
			velocity.x += 1
		if Input.is_action_pressed("ui_left"):
			velocity.x += -1
		if Input.is_action_pressed("ui_up"):
			velocity.y += -1
		if Input.is_action_pressed("ui_down"):
			velocity.y += 1

		if velocity != ZERO:
			direction = velocity	# salva o ultimo movimento do player

		if Input.is_action_just_pressed('dash'):
			dash()


func dash():
	if energy >= dash_cost:
		update_energy(-dash_cost)
		$DashTimer.start()

func update_energy(delta):
	energy += delta
	emit_signal('energy_changed', energy * 100 / max_energy)
	print("Energia: ", energy)	# @debug sp

func update_velocity():
	velocity = velocity.normalized() * base_speed
	if not $DashTimer.is_stopped():
		velocity = direction.normalized() * dash_speed


func _on_RegenTimer_timeout():
	if energy < max_energy:
		update_energy( min(energy_regen, max_energy-energy) )
