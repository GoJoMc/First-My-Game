extends CharacterBody2D

@export var speed = 120

var anim : AnimatedSprite2D
var is_attacking = false
var last_dir := Vector2.DOWN


func _ready():
	anim = $AnimatedSprite2D


func _physics_process(_delta):
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var dir = get_input_direction()

	if dir != Vector2.ZERO:
		last_dir = dir

	# attack
	if Input.is_action_just_pressed("attack"):
		attack(last_dir)
		return

	# movement
	velocity = dir * speed
	move_and_slide()

	update_anim(dir)


func get_input_direction() -> Vector2:
	var d = Vector2(
		int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left")),
		int(Input.is_action_pressed("ui_down"))  - int(Input.is_action_pressed("ui_up"))
	)

	return d.normalized() if d != Vector2.ZERO else Vector2.ZERO


func update_anim(dir):
	if is_attacking:
		return

	# idle state
	if dir == Vector2.ZERO:
		anim.animation = "idle_" + get_dir_name(last_dir)
		anim.play()
		return

	# walking state
	anim.animation = "walk_" + get_dir_name(dir)
	anim.flip_h = dir.x < 0
	anim.play()


func get_dir_name(vec: Vector2) -> String:
	# ngatur arah secara rapi
	if abs(vec.x) > abs(vec.y):
		return "right" if vec.x > 0 else "left"
	else:
		return "down" if vec.y > 0 else "up"


func attack(dir):
	if is_attacking:
		return

	is_attacking = true
	velocity = Vector2.ZERO

	var anim_name = "attack_" + get_dir_name(dir)

	# safety
	if not anim.sprite_frames.has_animation(anim_name):
		print("ANIM GA ADA:", anim_name)
		is_attacking = false
		return

	anim.animation = anim_name
	anim.flip_h = dir.x < 0
	anim.play()

	var sf = anim.sprite_frames
	var dur = sf.get_frame_count(anim_name) / max(sf.get_animation_speed(anim_name), 1)

	await get_tree().create_timer(dur).timeout

	is_attacking = false
