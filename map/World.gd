extends Node

# Sinais
signal points_changed

# Configuraveis
export (float) var max_expansion = 10
export (float) var shrink_delay = 7
export (float) var shrink_ratio = 0.1
export (int) var level_points = 1000
export (int) var enemy_max_points = 100
export (float) var max_hp_regen = 10

# Variaveis
var expansion
var base_damage
var base_attack_cooldown
var base_knockback_percent
var points


# Init
func _ready():
	points = 0
	emit_signal('points_changed', points)
	base_damage = $Player.damage
	base_attack_cooldown = $Player.attack_cooldown
	base_knockback_percent = $Player.knockback_percent
	$Shrink.wait_time = shrink_delay
	reset()


# Reset 100%
func reset():
	# normaliza a escala de tudo
	expansion = 1
	expand(0)
	# cura o player
	$Player.update_health($Player.max_health - $Player.health)
	# recupera energia, etc
	$Player.update_energy($Player.max_energy- $Player.energy)

# EXPANSAO
func expand(delta):
	var multiplier = expansion * (1 + delta*0.44)
	expansion *= 1 + delta

	$Player.scale.x = expansion
	$Player.scale.y = expansion
	$Player.attack_cooldown = base_attack_cooldown * expansion
	$Player.damage = base_damage * multiplier
	$Player.knockback_percent = base_knockback_percent * multiplier

	if (expansion >= max_expansion):
		invert()
	else:
		$Shrink.start()

# Transicao
func invert():
	points += level_points
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
	if expansion > 1:
		expand(-shrink_ratio)
	$Shrink.start()


# Ativada na morte de algum inimigo
func _on_enemy_death(ratio):
	expand(ratio)
	$Player.update_health(max_hp_regen * ratio)
	points += int(enemy_max_points * ratio)
	emit_signal('points_changed', points)

# Game Over
func _on_player_death():
	# Muda a pontuacao recorde
	if points > Global.high_score:
		Global.high_score = points
	# Carrega o menu
	get_tree().change_scene('res://GUI/Menu.tscn')

func _on_BackTrack_finished():
	$BackTrack.play()
