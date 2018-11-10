extends Node2D


# Sinais
signal enemy_death

# Configuraveis
export (float) var dispersion = 1.47
export (int) var initial_burst = 25
export (int) var burst_size = 10
export (float) var burst_delay = 16
export (PackedScene) var enemy

# Constantes
const max_expansion = 10


# Inicializacao / instanciacao na tree
func _ready():
	randomize()
	# numero inicial de inimigos
	burst(initial_burst)
	# os demais sao gerados a cada intervalo de timer
	$Timer.wait_time = burst_delay
	start()

func start():
	$Timer.start()

func stop():
	$Timer.stop()

func burst(n):
	for i in range(n):
		spawn()

func spawn():
	# cria um novo inimigo e conecta sinal de extensao
	var e = enemy.instance()
	e.connect('enemy_death', self, '_on_spawn_death')

	# randomiza tamanho e demais atributos consequentes
	var bonus = rand_range(1, max_expansion)
	bonus *= rand_range(0, 1)	# aumenta probabilidade de inimigos menores
	e.scale *= max(1, bonus)
	e.max_health *= max(1, bonus)
	e.damage *= max(1, bonus*0.95)
	e.base_speed /= max(1, bonus*0.85)
	e.chase_speed /= max(1, bonus*0.85)
	e.attack_cooldown *= max(1, bonus*0.85)
	e.roam_delay *= max(1, bonus*0.3)
	# esses dois ultimos ficaram levemente estranhos para valores altos de 'bonus'
	e.get_node('DetectRange').scale /= max(1, bonus*0.5)
	e.get_node('AttackRange').scale /= max(1, bonus*0.3)

	# centraliza uma area de spawn fechada na parte visivel do jogo
	var center = get_viewport_rect().position + get_viewport_rect().size/2
	var w = get_viewport_rect().size.x
	var h = get_viewport_rect().size.y

	# adiciona o inimigo na tree
	add_child(e)

	# posiciona aleatoriamente nessa area
	e.global_position.x = center.x + w*rand_range(-1, 1)*dispersion
	e.global_position.y = center.y + h*rand_range(-1, 1)*dispersion

	# som
	$SpawnSound.play()


# Gerador temporizado
func _on_timeout():
	burst(burst_size)
	$Timer.start()

# Repasse do sinal
func _on_spawn_death(enemy):
	var size_ratio = enemy.scale.y / max_expansion
	emit_signal('enemy_death', size_ratio)
	$DeathSound.play()
