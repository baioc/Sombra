extends "res://character/Character.gd"

# Sinais para os outros node
signal healthChanged

# Status do personagem
export (int) var max_energy = 100
var energy = max_energy

# Movimento do personagem
export (int) var dash_speed = 400
var direction = Vector2(1, 0)

# Variavel que vai selecionar a animaçao
enum ANIMATION_STATES { IDLE, LEFT, RIGHT, UP, DOWN, ATACK }
var animation = IDLE

# Estado do jogador (movendo,atacando,etc)
enum STATES { MOVE, ATTACK, DASH }
var playerState = MOVE

# Delay
export (float) var max_dashDelay = 0.5
export (float) var max_attackDelay = 0.2
var dashTimer = 0
var attackTimer = 0


# Loop
func control(delta):
	player_timing(delta)
	get_input(delta)
	movement()

func die():
	# @todo
	pass

# Input Events
func get_input(delta):
	# Movimento do personagem
	velocity = ZERO

	if playerState == MOVE:
		if Input.is_action_pressed("ui_right"):
			velocity.x += 1		# direçao que o jogador esta se movendo
			animation = RIGHT	# possivelmente usar nas animaçoes
		if Input.is_action_pressed("ui_left"):
			velocity.x += -1
			animation = LEFT
		if Input.is_action_pressed("ui_up"):
			velocity.y += -1
			animation = UP
		if Input.is_action_pressed("ui_down"):
			velocity.y += 1
			animation = DOWN

		if velocity != ZERO:
			direction = velocity # salva a direçao que o jogador estava se movendo


	# Atack do personagem
	if Input.is_action_just_pressed('attack'):
		playerState = ATTACK
		animation = ATACK

	# Dash do personagem
	if Input.is_action_just_pressed('dash'):
		playerState = DASH
		dashTimer = 0

	# Teste para a GUI de vida
	if Input.is_action_just_pressed('test_hp'):
		health -= 10
		emit_signal("healthChanged", health)


func player_timing(delta):
	# Timer das açoes do jogador e troca de states
	if playerState == ATTACK:
		attackTimer += delta
		if attackTimer >= max_attackDelay:
			playerState = MOVE
			attackTimer = 0

	# Tempo do dash
	if playerState == DASH:
		dashTimer += delta
		if dashTimer >= max_dashDelay:
			playerState = MOVE
			dashTimer = 0


func movement():
	if playerState == MOVE:
		velocity = velocity.normalized() * speed
	elif playerState == DASH:
		velocity = direction.normalized() * dash_speed
