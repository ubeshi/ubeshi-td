extends Node2D

func _init():
	# Runs when the scene initializes
	pass;
	
func _ready():
	# Whens when the scene loads (after init)
	pass;
	
func _process(delta):
	# Renders on every frame that has been rendered - depends on monitor refresh rate
	pass;
	
func _physics_process(delta):
	# Runs on every physics frame (different than render)
	# Edit this in Project -> Project Settings -> Physics
	turn()
	
func turn():
	var enemy_position = get_global_mouse_position();
	get_node("Turret").look_at(enemy_position);
