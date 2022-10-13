extends Node2D

var type;
var enemy_array = [];
var built = false;
var enemy;
var ready = true;
var category;

var missile1_node;
var missile2_node;
var isLeftMissileFired = false;

signal fire_missile(base_position, enemy, damage);

func _init():
    # Runs when the scene initializes
    pass;

func _ready():
    if built:
        if (category == "Missile"):
            missile1_node = self.get_node("Turret/Missile1");
            missile2_node = self.get_node("Turret/Missile2");
        self.get_node("Range/CollisionShape2D").get_shape().radius = 0.5 * GameData.tower_data[type]["range"];

func _process(delta):
    # Renders on every frame that has been rendered - depends on monitor refresh rate
    pass;

func _physics_process(delta):
    # Runs on every physics frame (different than render)
    # Edit this in Project -> Project Settings -> Physics
    if enemy_array.size() != 0 and built:
        select_enemy();
        if get_node_or_null("AnimationPlayer") and not get_node("AnimationPlayer").is_playing():
            turn();
        if ready:
            fire();
    else:
        enemy = null;

func select_enemy():
    var enemy_progress_array = [];
    for i in enemy_array:
        if i.offset:
            enemy_progress_array.append(i.offset);
    var max_offset = enemy_progress_array.max();
    var enemy_index = enemy_progress_array.find(max_offset);
    enemy = enemy_array[enemy_index];

func fire():
    ready = false;
    if category == "Projectile":
        fire_projectile();
        enemy.on_hit(GameData.tower_data[type]["damage"]);
    elif category == "Missile":
        fire_missile();
    yield(get_tree().create_timer(GameData.tower_data[type]["rof"]), "timeout");
    ready = true;

func fire_projectile():
    get_node("AnimationPlayer").play("Fire");

func fire_missile():
    if (!isLeftMissileFired):
        get_node("AnimationPlayerMissile1").play("FireMissile");
        emit_signal("fire_missile", self.position + missile1_node.position, enemy, GameData.tower_data[type]["damage"]);
        isLeftMissileFired = true;
    else:
        get_node("AnimationPlayerMissile2").play("FireMissile");
        emit_signal("fire_missile", self.position + missile2_node.position, enemy, GameData.tower_data[type]["damage"]);
        isLeftMissileFired = false;

func turn():
    get_node("Turret").look_at(enemy.position);

func _on_Range_body_entered(body):
    if (body.name == "TankKBody"):
        enemy_array.append(body.get_parent());

func _on_Range_body_exited(body):
    if (body.name == "TankKBody"):
        enemy_array.erase(body.get_parent());
