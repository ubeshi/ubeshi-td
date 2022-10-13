extends Node

func _ready():
    load_main_menu();

func load_main_menu():
    get_node("MainMenu/Margin/VBoxContainer/NewGame").connect("pressed", self, "on_new_game_pressed");
    get_node("MainMenu/Margin/VBoxContainer/Quit").connect("pressed", self, "on_quit_pressed");

func on_new_game_pressed():
    get_node("MainMenu").queue_free();
    var game_scene = load("res://scene/main-scene/GameScene.tscn").instance();
    game_scene.connect("game_finished", self, "unload_game");
    add_child(game_scene);

func unload_game(result):
    get_node("GameScene").queue_free();
    var main_menu = load("res://scene/turret/MainMenu.tscn").instance();
    add_child(main_menu);
    load_main_menu();

func on_quit_pressed():
    if !OS.has_feature('JavaScript'):
        get_tree().quit();
