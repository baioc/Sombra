extends Node


# Constantes para o crescimento
const MIN = 0.01
const START = 1
const MAX = 42
const DELTA = 1

# Prefabs
export (PackedScene) var map
export (PackedScene) var fx

# Atributos
var current_map
var shadow_map
var scale


func _ready():
	# instancia dois mapas diferentes
	current_map = map.instance()
	shadow_map = map.instance()
	# inverte um deles
	var negative = fx.instance()
	shadow_map.find_node('Camera').add_child(negative)
	reset()

func _physics_process(delta):
	if Input.is_action_just_pressed('test_expand'):
		expand(DELTA)
	elif Input.is_action_just_pressed('test_shrink'):
		expand(-DELTA)


# Testando EXPANSAO
func expand(delta):
	scale = scale + delta if scale + delta > MIN else scale

	var player = current_map.find_node('Player')
	player.scale.x = scale
	player.scale.y = scale

	var shadow_scale = range_lerp(scale, START, MAX, MIN, START)	# interpolacao linear
	shadow_map.scale.x = shadow_scale
	shadow_map.scale.y = shadow_scale

	print("Scaling: ", scale, ", ", shadow_scale)	# @debug expand
	if (scale >= MAX):
		swap()

# transicao entre mapas @todo melhorar, fazer o outro mapa visivel atraves do player antes da troca
func swap():
	remove_child(current_map)
	var temp = current_map
	current_map = shadow_map
	shadow_map = temp
	reset()

# reseta escala dos mapas
func reset():
	var player = current_map.find_node('Player')
	player.scale.x = START
	player.scale.y = START

	current_map.scale.x = START
	current_map.scale.y = START

	shadow_map.scale.x = MIN
	shadow_map.scale.y = MIN

	scale = START
	add_child(current_map)	# apenas o mapa atual esta "rodando"
