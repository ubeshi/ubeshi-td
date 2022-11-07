extends Node2D

var type;
var enemy_array = [];
var built = false;
var enemy;
var ready = true;
var category;
var title;
var description;

signal on_tower_select(title, description);

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
    # Override in child
    pass;

func turn():
    get_node("Turret").look_at(enemy.position);

func _on_Select_input_event(viewport, event, _shape_idx):
    if event is InputEventMouseButton:
        if event.button_index == BUTTON_LEFT and event.pressed:
            emit_signal("on_tower_select", title, description);

func _on_Range_body_entered(body):
    if (body.name == "TankKBody"):
        enemy_array.append(body.get_parent());

func _on_Range_body_exited(body):
    if (body.name == "TankKBody"):
        enemy_array.erase(body.get_parent());
