extends Node2D


signal enemy_death

export (float) var dispersion = 1.47
export (int) var initial_burst = 20
export (int) var burst_size = 9
export (float) var burst_delay = 18
export (PackedScene) var enemy


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
	# centraliza uma area de spawn fechada na parte visivel do jogo
	var center = get_viewport_rect().position + get_viewport_rect().size/2
	var w = get_viewport_rect().size.x
	var h = get_viewport_rect().size.y

	# cria um novo inimigo e o posiciona aleatoriamente nessa area
	var e = enemy.instance()
	e.connect('enemy_death', self, '_on_spawn_death')
	add_child(e)
	e.global_position.x = center.x + w*rand_range(-1, 1)*dispersion
	e.global_position.y = center.y + h*rand_range(-1, 1)*dispersion


func _on_timeout():
	burst(burst_size)
	$Timer.start()

func _on_spawn_death():	# passa adiante o sinal
	emit_signal('enemy_death')
