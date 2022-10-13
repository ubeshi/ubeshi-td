extends PathFollow2D

var speed = 150;
var hp = 150;
var base_damage = 21;

signal base_damage(damage);
signal destroyed_with_bounty(bounty_amount);

onready var health_bar = get_node("HealthBar");
onready var impact_area = get_node("Impact");

signal enemy_destroy();
var isAlive = true;

var projectile_impact = preload("res://scene/support-scene/ProjectileImpact.tscn");

func _ready():
    health_bar.max_value = 150;
    health_bar.value = health_bar.max_value;
    health_bar.set_as_toplevel(true);

func _physics_process(delta):
    if unit_offset == 1.0:
        emit_signal("base_damage", base_damage);
        queue_free();
    move(delta);

func move(delta):
    set_offset(get_offset() + speed * delta);
    health_bar.set_position(position - Vector2(30, 30));

func on_hit(damage):
    if (isAlive):
        impact();
        print(health_bar.value);
        hp -= damage;
        health_bar.value = hp;
        if (hp <= 0):
            on_destroy();

func impact():
    randomize();
    var x_pos = randi() % 31;
    randomize();
    var y_pos = randi() % 31;
    var impact_location = Vector2(x_pos, y_pos);
    var new_impact = projectile_impact.instance();
    new_impact.position = impact_location;
    impact_area.add_child(new_impact);

func on_destroy():
    isAlive = false;
    emit_signal("destroyed_with_bounty", 1);
    # get_node("KBody").queue_free();
    yield(get_tree().create_timer(0.2), "timeout");
    self.queue_free();
