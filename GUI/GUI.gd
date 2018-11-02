extends MarginContainer


var current_health

onready var bar = $Status/LifeBar/TextureProgress


func _ready():
	var player_max_health = $"../../Player".max_health	#@fixme
	bar.max_value = player_max_health
	update_Health(player_max_health)

func update_Health(new_value):
	current_health = new_value

func _process(delta):
	bar.value = current_health

func _on_Player_healthChanged(player_health):
	print(current_health," HP, pora")
	update_Health(player_health)
