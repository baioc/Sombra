extends TextureProgress


var initialized = false


func _on_value_changed(new):
	if not initialized:
		min_value = 0
		max_value = new
		initialized = true
	value = new
