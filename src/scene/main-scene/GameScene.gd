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

func _ready():
    map_node = get_node("Map1"); ## Turn this into a variable based on selected map
    for i in get_tree().get_nodes_in_group("build_buttons"):
        i.connect("pressed", self, "initiate_build_mode", [i.get_name()]);

func _process(delta):
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
    build_mode = true;
    get_node("UI").set_tower_preview(build_type, get_global_mouse_position());

func update_tower_preview():
    var mouse_position = get_global_mouse_position();
    var current_tile = map_node.get_node("TowerExclusion").world_to_map(mouse_position);
    var tile_position = map_node.get_node("TowerExclusion").map_to_world(current_tile);

    if map_node.get_node("TowerExclusion").get_cellv(current_tile) == -1:
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
        new_tower.category = GameData.tower_data[build_type]["category"];
        new_tower.connect("fire_missile", self, "on_fire_missile");
        map_node.get_node("Turrets").add_child(new_tower, true);
        map_node.get_node("TowerExclusion").set_cellv(build_tile, 5);
        # Update cash

func on_base_damage(damage):
    base_health -= damage;
    if base_health <= 0:
        emit_signal("game_finished", false);
    else:
        get_node("UI").update_health_bar(base_health);
    decrement_enemy_wave();

func on_fire_missile(position, enemy, damage):
    var new_missile = load("res://scene/support-scene/Missile.tscn").instance();
    new_missile.position = position + Vector2(30, 30);
    new_missile.enemy = enemy;
    new_missile.velocity = enemy.position - position;
    new_missile.damage = damage;
    map_node.get_node("Projectiles").add_child(new_missile, true);
    new_missile.look_at(enemy.position);
