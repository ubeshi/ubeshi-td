extends KinematicBody2D

var velocity = Vector2(1, 0);
var speed = 1000;
var enemy;
var damage;

func _physics_process(delta):
    var collision_info = move_and_collide(velocity.normalized() * delta * speed)
    if collision_info:
        print(collision_info.get_collider().get_parent());
        print("hit");
        collision_info.get_collider().get_parent().on_hit(damage);
        self.free()
