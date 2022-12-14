extends CanvasLayer

onready var hp_bar = get_node("HUD/InfoBar/HBoxContainer/HP");
onready var hp_bar_tween = get_node("HUD/InfoBar/HBoxContainer/HP/Tween");
onready var wave_number = get_node("HUD/WaveBar/HBoxContainer/Wave");
onready var enemy_count = get_node("HUD/WaveBar/HBoxContainer/Enemies");

func set_tower_preview(tower_type, mouse_position):
    var drag_tower = load("res://scene/turret/" + tower_type + ".tscn").instance();
    drag_tower.set_name("DragTower");
    drag_tower.modulate = Color(GameData.ubeshi_color.GREEN_TRANSPARENT);

    var range_texture = Sprite.new();
    range_texture.position = Vector2(32, 32);
    var scaling = GameData.tower_data[tower_type]["range"] / 600.0;
    range_texture.scale = Vector2(scaling, scaling);
    var texture = load("res://asset/environment/tileset/range_overlay.png");
    range_texture.texture = texture;
    range_texture.modulate = Color(GameData.ubeshi_color.GREEN_TRANSPARENT);

    var control = Control.new();
    control.add_child(range_texture, true);
    control.add_child(drag_tower, true);
    control.rect_position = mouse_position;
    control.set_name("TowerPreview");
    add_child(control, true);
    move_child(get_node("TowerPreview"), 0);

func update_tower_preview(new_position, color):
    get_node("TowerPreview").rect_position = new_position;
    if (get_node("TowerPreview/DragTower").modulate != Color(color)):
        get_node("TowerPreview/DragTower").modulate = Color(color);
        get_node("TowerPreview/Sprite").modulate = Color(color);

##
## Game control functions
##

func _on_PausePlay_pressed():
    if get_parent().build_mode:
        get_parent().cancel_build_mode();
    if get_tree().is_paused():
        get_tree().paused = false;
    else:
        get_tree().paused = true;

func _on_Speedup_pressed():
    if get_parent().build_mode:
        get_parent().cancel_build_mode();
    if Engine.get_time_scale() == 2.0:
        Engine.set_time_scale(1.0);
    else:
        Engine.set_time_scale(2.0);

func update_enemy_count(count):
    enemy_count.text = str(count);

func update_wave_number(wave):
    wave_number.text = str(wave);

func update_health_bar(base_health):
    hp_bar_tween.interpolate_property(hp_bar, "value", hp_bar.value, base_health, 0.1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT);
    hp_bar_tween.start();
    if base_health >= 60:
        hp_bar.set_tint_progress(GameData.ubeshi_color.GREEN);
    elif base_health < 60 and base_health >= 25:
        hp_bar.set_tint_progress(GameData.ubeshi_color.ORANGE);
    elif base_health < 25:
        hp_bar.set_tint_progress(GameData.ubeshi_color.RED);

func _on_NextWaveButton_pressed():
    if get_parent().current_wave < 5:
        get_parent().current_wave += 1;
    get_parent().start_next_wave();
    update_wave_number(get_parent().current_wave);
