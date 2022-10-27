extends "res://scene/turret/Turrets.gd"

func _ready():
  ._ready();
  if built:
    missile1_node = self.get_node("Turret/Missile1");
    missile2_node = self.get_node("Turret/Missile2");

func fire():
  ready = false;
  if (!isLeftMissileFired):
    get_node("AnimationPlayerMissile1").play("FireMissile");
    emit_signal("fire_missile", self.position + missile1_node.position, enemy, GameData.tower_data[type]["damage"]);
    isLeftMissileFired = true;
  else:
    get_node("AnimationPlayerMissile2").play("FireMissile");
    emit_signal("fire_missile", self.position + missile2_node.position, enemy, GameData.tower_data[type]["damage"]);
    isLeftMissileFired = false;
  yield(get_tree().create_timer(GameData.tower_data[type]["rof"]), "timeout");
  ready = true;
