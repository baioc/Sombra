extends MarginContainer

# Apenas passa adiante os sinais recebidos

func _on_Player_health_changed(hp):
	$Status/HealthCircle._on_value_changed(hp)

func _on_Player_energy_changed(sp):
	$Status/EnergyBar._on_value_changed(sp)

func _on_points_changed(pt):
	$Points/Label.text = str(pt)
