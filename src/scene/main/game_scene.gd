extends Node

var map_node

func _ready():
	map_node = self
	spawn_wave()

func spawn_wave():
	var enemies = [["blue_tank", 0.7], ["blue_tank", 0.1]]
	for enemy in enemies:
		var new_enemy = load("res://scene/enemies/" + enemy[0] + ".tscn").instance()
		spawn_enemy(new_enemy, enemy[1])

func spawn_enemy(enemy, timeout):
	map_node.get_node("Path").add_child(enemy, true)
	yield(get_tree().create_timer(timeout), "timeout")
