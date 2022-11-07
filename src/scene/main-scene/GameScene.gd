extends Node2D

signal game_finished(result)

var map_node

var build_mode = false
var build_valid = false
var build_tile
var build_location
var build_type

var current_wave = 0
var enemies_in_wave = 0
var base_health = 100

var money_node
var starting_money = 1000
var current_money = starting_money

var a_star
var path_2d
var map_x_offset = 0
var map_y_offset = 1
var map_cell_size = 64
var map_width = 20
var map_height = 10
var map_enemy_spawn_point_id = 0
var map_enemy_goal_point_id = 199

func _ready():
    money_node = get_node("UI/HUD/InfoBar/HBoxContainer/Money");
    money_node.text = str(current_money);
    map_node = get_node("Map1"); ## Turn this into a variable based on selected map
    path_2d = map_node.get_node("Path");
    initialize_enemy_path();
    for i in get_tree().get_nodes_in_group("build_buttons"):
        i.connect("pressed", self, "initiate_build_mode", [i.get_name()]);

func _process(_delta):
    if build_mode:
        update_tower_preview();

func _unhandled_input(event):
    if event.is_action_released("ui_cancel") and build_mode == true:
        cancel_build_mode();
    if event.is_action_released("ui_accept") and build_mode == true:
        verify_and_build();
        cancel_build_mode();

##
## Wave Functions
##

func start_next_wave():
    var wave_data = retrieve_wave_data();
    yield(get_tree().create_timer(0.2), "timeout"); # Padding between waves so they do not start instantly.
    spawn_enemy_wave(wave_data);

func retrieve_wave_data():
    var enemies = GameData.wave_data[current_wave];
    enemies_in_wave += enemies.size();
    get_node("UI").update_enemy_count(enemies_in_wave);
    return enemies;

func spawn_enemy_wave(enemies):
    for enemy in enemies:
        var new_enemy = load("res://scene/enemies/" + enemy[0] + ".tscn").instance();
        new_enemy.connect("base_damage", self, "on_base_damage");
        new_enemy.connect("enemy_destroy", self, "on_enemy_destroy");
        new_enemy.connect("destroyed_with_bounty", self, "add_money");
        map_node.get_node("Path").add_child(new_enemy, true);
        yield(get_tree().create_timer(enemy[1]), "timeout");

func on_enemy_destroy():
    decrement_enemy_wave();

func decrement_enemy_wave():
    enemies_in_wave -= 1;
    if enemies_in_wave < 0:
        enemies_in_wave = 0;
    get_node("UI").update_enemy_count(enemies_in_wave);

##
## Build Functions
##

func initiate_build_mode(tower_type):
    if build_mode:
        cancel_build_mode();
    build_type = tower_type + "T1";

    var tower_cost = GameData.tower_data[build_type].cost;
    if (tower_cost > current_money):
        return;

    build_mode = true;
    get_node("UI").set_tower_preview(build_type, get_global_mouse_position());

func update_tower_preview():
    var mouse_position = get_global_mouse_position();
    var current_tile = map_node.get_node("TowerExclusion").world_to_map(mouse_position);
    var tile_position = map_node.get_node("TowerExclusion").map_to_world(current_tile);

    var is_tile_valid = map_node.get_node("TowerExclusion").get_cellv(current_tile) == -1;
    if is_tile_valid:
        get_node("UI").update_tower_preview(tile_position, GameData.ubeshi_color.GREEN_TRANSPARENT);
        build_valid = true;
        build_location = tile_position;
        build_tile = current_tile;
    else:
        get_node("UI").update_tower_preview(tile_position, GameData.ubeshi_color.LIME_TRANSPARENT);
        build_valid = false;

func cancel_build_mode():
    build_mode = false;
    build_valid = false;
    get_node("UI/TowerPreview").free();

func verify_and_build():
    if build_valid:
        var new_tower = load("res://scene/turret/" + build_type + ".tscn").instance();
        new_tower.position = build_location;
        new_tower.built = true;
        new_tower.type = build_type;
        new_tower.title = GameData.tower_data[build_type]["title"];
        new_tower.description = GameData.tower_data[build_type]["description"];
        new_tower.category = GameData.tower_data[build_type]["category"];
        new_tower.connect("on_tower_select", self, "on_tower_select");
        new_tower.connect("fire_missile", self, "on_fire_missile");
        map_node.get_node("Turrets").add_child(new_tower, true);
        map_node.get_node("TowerExclusion").set_cellv(build_tile, 5);
        # Update cash
        var tower_cost = GameData.tower_data[build_type].cost;
        obstruct_path_at_location(build_location);
        add_money(-1 * tower_cost);

func on_tower_select(title, description):
    var ui_title = get_node("UI/HUD/DetailBar/VBoxContainer/TurretTitle");
    var ui_description = get_node("UI/HUD/DetailBar/VBoxContainer/TurretDescription");
    var ui_detailbar = get_node("UI/HUD/DetailBar");
    
    if !ui_detailbar.visible:
        ui_detailbar.visible = true; 
    
    ui_title.text = title;
    ui_description.text = description;

func on_base_damage(damage):
    base_health -= damage;
    if base_health <= 0:
        emit_signal("game_finished", false);
    else:
        get_node("UI").update_health_bar(base_health);
    decrement_enemy_wave();

func add_money(amount):
    current_money += amount;
    money_node.text = str(current_money);

func on_fire_missile(position, enemy, damage):
    var new_missile = load("res://scene/support-scene/Missile.tscn").instance();
    new_missile.position = position + Vector2(30, 30);
    new_missile.enemy = enemy;
    new_missile.velocity = enemy.position - position;
    new_missile.damage = damage;
    map_node.get_node("Projectiles").add_child(new_missile, true);
    new_missile.look_at(enemy.position);

func _on_DetailBarCancelButton_pressed():
    var ui_detailbar = get_node("UI/HUD/DetailBar");
    ui_detailbar.visible = false;

func initialize_enemy_path() -> void:
    var point_translation = UbeshiAStar.PointTranslation.new(map_x_offset, map_y_offset);
    a_star = UbeshiAStar.get_new_map(map_width, map_height, point_translation);
    update_path(a_star);

func obstruct_path_at_location(location: Vector2) -> void:
    var centered_x = location.x + map_cell_size / 2;
    var centered_y = location.y + map_cell_size / 2;
    var vector3 = Vector3(centered_x, centered_y, 0);
    var point_id = a_star.get_closest_point(vector3, true);
    a_star.set_point_disabled(point_id, true);
    update_path(a_star);

func update_path(a_star: AStar) -> void:
    var point_array = UbeshiAStar.get_pool_vector2_array(a_star, map_enemy_spawn_point_id, map_enemy_goal_point_id);
    UbeshiAStar.replace_path_2d_points_with_vector2_array(path_2d, point_array);
