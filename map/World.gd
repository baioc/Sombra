extends Node


const MIN = 0.01
const START = 1
const MAX = 42
const DELTA = 1

export (PackedScene) var map
export (PackedScene) var fx

var current_map
var shadow_map
var scale


func _ready():
	current_map = map.instance()
	shadow_map = map.instance()
	var negative = fx.instance()
	shadow_map.find_node("Camera").add_child(negative)
	reset()

func _physics_process(delta):
	if Input.is_action_just_pressed('test_expand'):
		expand(DELTA)
	elif Input.is_action_just_pressed('test_shrink'):
		expand(-DELTA)


func expand(delta):
	scale = scale + delta if scale + delta > MIN else scale
	var shadow_scale = range_lerp(scale, START, MAX, MIN, START)

	var player = current_map.find_node("Player")

	player.scale.x = scale
	player.scale.y = scale
	shadow_map.scale.x = shadow_scale
	shadow_map.scale.y = shadow_scale

	print("Scaling: ", scale, ", ", shadow_scale)	# @debug expand
	if (scale >= MAX):
		swap()

func swap():	# @todo melhorar transicao
	remove_child(current_map)
	var temp = current_map
	current_map = shadow_map
	shadow_map = temp
	reset()

func reset():
	shadow_map.scale.x = MIN
	shadow_map.scale.y = MIN

	var player = current_map.find_node("Player")
	player.scale.x = START
	player.scale.y = START

	current_map.scale.x = START
	current_map.scale.y = START

	scale = START
	add_child(current_map)
