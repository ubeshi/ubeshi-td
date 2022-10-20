extends "res://scene/turret/Turrets.gd"

func fire():
  ready = false;
  get_node("AnimationPlayer").play("Fire");
  enemy.on_hit(GameData.tower_data[type]["damage"]);
  yield(get_tree().create_timer(GameData.tower_data[type]["rof"]), "timeout");
  ready = true;
