extends Node

# Sinais
signal points_changed

# Configuraveis
export (float) var max_expansion = 10
export (float) var shrink_delay = 7
export (float) var shrink_ratio = 0.1
export (float) var max_hp_regen = 10

# Constantes
const PT_LEVEL = 420
const PT_ENEMY = 50

# Variaveis
var expansion
var base_damage
var base_attack_cooldown
var points


# Init
func _ready():
	points = 0
	emit_signal('points_changed', points)
	base_damage = $Player.damage
	base_attack_cooldown = $Player.attack_cooldown
	$Shrink.wait_time = shrink_delay
	reset()


# Reset 100%
func reset():
	# cura o player
	$Player.health = $Player.max_health
	$Screen/GUI._on_Player_health_changed(100)
	# recupera energia, etc
	$Player.energy = $Player.max_energy
	$Screen/GUI._on_Player_energy_changed(100)
	# normaliza o tamanho
	expansion = 1
	expand(0)

# EXPANSAO
func expand(delta):
	var multiplier = expansion * (1 + delta*0.44)
	expansion *= 1 + delta

	$Player.scale.x = expansion
	$Player.scale.y = expansion
	$Player.attack_cooldown = base_attack_cooldown * expansion * 2
	$Player.damage = base_damage * multiplier

	if (expansion >= max_expansion):
		invert()
	else:
		$Shrink.start()

# Transicao
func invert():
	points += PT_LEVEL
	emit_signal('points_changed', points)
	$Animator.play('invert')
	$Player/ExpandSound.play()
	get_tree().paused = true


# Fim da transicao
func _on_animation_finished(anim_name):
	if anim_name == 'invert':
		get_tree().paused = false
		get_tree().set_input_as_handled()

		if $Screen/Negate.visible:
			$Screen/Negate.hide()
		else:
			$Screen/Negate.show()

		reset()

# Reducao temporizada do tamanho
func _on_ShrinkTimer_timeout():
	if expansion >= 1:
		expand(-shrink_ratio)
	$Shrink.start()


# Ativada na morte de algum inimigo
func _on_enemy_death(ratio):
	expand(ratio)
	$Player.health += max_hp_regen * ratio
	$Screen/GUI._on_Player_health_changed($Player.health * 100 / $Player.max_health)
	points += int(PT_ENEMY * ratio)
	emit_signal('points_changed', points)
