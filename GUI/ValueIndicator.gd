extends TextureProgress

func _ready():
	min_value = 0
	max_value = 100
	value = max_value

func _on_value_changed(new):	# new : [0, 100] %
	value = new
