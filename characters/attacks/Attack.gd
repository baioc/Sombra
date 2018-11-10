extends Area2D

export (int) var damage = 0

func execute(damage=null, mask=null):
	if $Animator.has_animation('attack'):
		$Animator.play('attack')
	if damage:
		self.damage = damage
	if mask:	# define o que pode ser atingido
		collision_mask = mask

func _on_Attack_body_entered(body):
	if body.has_method('take_hit') and not body.is_a_parent_of(self):
		body.take_hit(damage, body.global_position - get_parent().global_position)

func _on_Animator_animation_finished(anim_name):
	if anim_name == 'attack':
		queue_free()
