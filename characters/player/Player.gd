extends "res://characters/Character.gd"


# Movimento do personagem
export (int) var dash_speed = 400
var direction = Vector2(1, 0)

# Energia
export (int) var max_energy = 100
export (int) var dash_cost = 25
export (int) var energy_regen = 5
signal energy_changed
var energy

# Timing
export (float) var dash_duration = 0.666
export (float) var energy_regen_delay = 0.7


# Inicializacao
func _ready():
	energy = max_energy
	$Camera.current = true
	$DashTimer.wait_time = dash_duration
	$RegenTimer.wait_time = energy_regen_delay


# Loop
func control(delta):
	get_input()
	update_velocity()

func die():
	print("* GAME OVER *")
	queue_free()


# @note seria melhor usar o metodo pronto de input
func get_input():
	# Ataque
	if Input.is_action_just_pressed('attack'):
		attack(direction)

	# Dash
	if Input.is_action_just_pressed('dash'):
		if $DashTimer.is_stopped():
			dash()
		else:	# para o dash se apertar denovo
			$DashTimer.stop()

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

		# salva o ultimo movimento do player
		if velocity != ZERO:
			direction = velocity


func dash():
	if energy >= dash_cost:
		update_energy(-dash_cost)
		$DashTimer.start()
		$ActionSound.play()

func update_energy(delta):
	energy += delta
	emit_signal('energy_changed', energy * 100 / max_energy)

# Aplica movimentacao
func update_velocity():
	velocity = velocity.normalized() * base_speed
	if not $DashTimer.is_stopped():
		velocity = direction.normalized() * dash_speed

# Regeneracao de energia
func _on_RegenTimer_timeout():
	if energy < max_energy:
		update_energy( min(energy_regen, max_energy-energy) )
