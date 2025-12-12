extends CharacterBody2D

@onready var target = $"../Player"

var speed = 120

func _physics_process(_delta):
	if target:
		var dir = (target.position - position).normalized()
		velocity = dir * speed
		look_at(target.position)  # hapus ini kalo gak mau enemy muter2
		move_and_slide()
