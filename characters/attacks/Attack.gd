extends Area2D

var damage = 0

func execute(damage):
	self.damage = damage
	if $Animator.has_animation('attack'):
		$Animator.play('attack')

func _on_Attack_body_entered(body):
	if body.has_method('lose_health'):
		body.lose_health(damage)

func _on_Animator_animation_finished(anim_name):
	if anim_name == 'attack':
		queue_free()
