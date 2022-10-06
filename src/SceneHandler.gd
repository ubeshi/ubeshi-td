extends Node

func _ready():
    get_node("MainMenu/Margin/VBoxContainer/NewGame").connect("pressed", self, "on_new_game_pressed");
    get_node("MainMenu/Margin/VBoxContainer/Quit").connect("pressed", self, "on_quit_pressed");
    
func on_new_game_pressed():
    get_node("MainMenu").queue_free();
    var game_scene = load("res://scene/main-scene/GameScene.tscn").instance();
    add_child(game_scene);
        
func on_quit_pressed():
    if !OS.has_feature('JavaScript'):
        get_tree().quit();
