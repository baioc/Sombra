extends Area2D

export (int) var damage = 0

func execute(damage=null, mask=null):
	if $Animator.has_animation('attack'):
		$Animator.play('attack')
	if damage:
		self.damage = damage
	if mask:	# define o que pode ser atingido
		set_collision_mask(mask)

func _on_Attack_body_entered(body):
	if body.has_method('update_health') and not body.is_a_parent_of(self):
		body.update_health(-damage, body.get_global_position() - get_parent().get_global_position())

func _on_Animator_animation_finished(anim_name):
	if anim_name == 'attack':
		queue_free()
