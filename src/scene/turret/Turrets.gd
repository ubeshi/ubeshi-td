extends Node2D

var type;
var enemy_array = [];
var built = false;
var enemy;
var ready = true;
var category;

func _init():
	# Runs when the scene initializes
	pass;

func _ready():
	if built:
		self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * GameData.tower_data[type]["range"];

func _process(delta):
	# Renders on every frame that has been rendered - depends on monitor refresh rate
	pass;

func _physics_process(delta):
	# Runs on every physics frame (different than render)
	# Edit this in Project -> Project Settings -> Physics
	if enemy_array.size() != 0 and built:
		select_enemy();
		if not get_node("AnimationPlayer").is_playing():
			turn();
		if ready:
			fire();
	else:
		enemy = null;

func select_enemy():
	var enemy_progress_array = [];
	for i in enemy_array:
		enemy_progress_array.append(i.offset);
	var max_offset = enemy_progress_array.max();
	var enemy_index = enemy_progress_array.find(max_offset);
	enemy = enemy_array[enemy_index];

func fire():
	ready = false;
	if category == "Projectile":
		fire_projectile();
	elif category == "Missile":
		fire_missile();
	enemy.on_hit(GameData.tower_data[type]["damage"]);
	yield(get_tree().create_timer(GameData.tower_data[type]["rof"]), "timeout");
	ready = true;

func fire_projectile():
	get_node("AnimationPlayer").play("Fire");

func fire_missile():
	pass;

func turn():
	get_node("Turret").look_at(enemy.position);

func _on_Range_body_entered(body):
	enemy_array.append(body.get_parent());

func _on_Range_body_exited(body):
	enemy_array.erase(body.get_parent());
