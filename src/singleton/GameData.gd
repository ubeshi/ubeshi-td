extends Node

var tower_data = {
    "GunT1": {
        "damage": 20,
        "rof": 0.3,
        "range": 350,
        "category": "Projectile",
    },
    "MissileT1": {
        "damage": 100,
        "rof": 3,
        "range": 550,
        "category": "Missile"
    },
}

var ubeshi_color = {
    "GREEN": "4EFF15",
    "ORANGE": "E1BE32",
    "RED": "E11E1E",
    "GREEN_TRANSPARENT": "AD54FF3C",
    "LIME_TRANSPARENT": "ADFF4545",
}

var wave_data = {
    1: [["blue_tank", 0.7], ["blue_tank", 1.0], ["blue_tank", 1.0], ["blue_tank", 1.0], ["blue_tank", 1.0]],
    2: [["blue_tank", 0.7], ["blue_tank", 1.0], ["blue_tank", 1.0], ["blue_tank", 1.0], ["blue_tank", 1.0]],
    3: [["blue_tank", 0.7], ["blue_tank", 1.0], ["blue_tank", 1.0], ["blue_tank", 1.0], ["blue_tank", 1.0]],
    4: [["blue_tank", 0.7], ["blue_tank", 1.0], ["blue_tank", 1.0], ["blue_tank", 1.0], ["blue_tank", 1.0]],
    5: [["blue_tank", 0.7], ["blue_tank", 1.0], ["blue_tank", 1.0], ["blue_tank", 1.0], ["blue_tank", 1.0]],   
}
