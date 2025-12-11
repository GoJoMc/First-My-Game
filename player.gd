extends CharacterBody2D

@export var speed = 120

var anim : AnimatedSprite2D
var is_attacking = false
var last_dir := Vector2.DOWN


func _ready():
	anim = $AnimatedSprite2D


func _physics_process(delta):
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
		int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	)
	return d.normalized() if d != Vector2.ZERO else Vector2.ZERO


func update_anim(dir):
	if is_attacking:
		return

	if dir == Vector2.ZERO:
		var cur = anim.animation
		if cur.begins_with("walk"):
			anim.animation = cur.replace("walk", "idle")
		return

	var a = ""
	if dir.y > 0:
		a = "walk_down"
	elif dir.y < 0:
		a = "walk_up"
	elif dir.x > 0:
		a = "walk_right"
	elif dir.x < 0:
		a = "walk_left"

	anim.flip_h = last_dir.x < 0
	anim.animation = a
	anim.play()


func attack(dir):
	if is_attacking:
		return

	is_attacking = true
	velocity = Vector2.ZERO

	var a = ""
	if dir.y > 0:
		a = "attack_down"
	elif dir.y < 0:
		a = "attack_up"
	elif dir.x > 0:
		a = "attack_right"
	else:
		a = "attack_left"

	# safety check (biar ga crash)
	if not anim.sprite_frames.has_animation(a):
		print("ANIM GA ADA:", a)
		is_attacking = false
		return

	anim.animation = a
	anim.play()

	var sf = anim.sprite_frames
	var frames = sf.get_frame_count(a)
	var fps = max(sf.get_animation_speed(a), 1)
	var dur = frames / fps

	await get_tree().create_timer(dur).timeout

	is_attacking = false
