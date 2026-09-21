extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -800.0

# Ghost Boost
const GHOST_DURATION = 5.0
const GHOST_COOLDOWN = 10.0
const GHOST_SPEED_MULTIPLIER = 2

var is_ghosting: bool = false
var ghost_timer: float = 0.0
var ghost_cooldown_timer: float = 0.0


func _physics_process(delta: float) -> void:
	# -------------------------
	# Ghost Boost
	# -------------------------

	if Input.is_action_just_pressed("blue-ghost"):
		if not is_ghosting and ghost_cooldown_timer <= 0.0:
			is_ghosting = true
			ghost_timer = GHOST_DURATION

	if is_ghosting:
		ghost_timer -= delta

		if ghost_timer <= 0.0:
			is_ghosting = false
			ghost_cooldown_timer = GHOST_COOLDOWN

	elif ghost_cooldown_timer > 0.0:
		ghost_cooldown_timer -= delta


	# -------------------------
	# Animation
	# -------------------------

	if velocity.x != 0:
		animated_sprite_2d.animation = "run"
		animated_sprite_2d.play()
	else:
		animated_sprite_2d.animation = "idle"


	# -------------------------
	# Gravity
	# -------------------------

	if not is_on_floor():
		velocity += get_gravity() * delta
		animated_sprite_2d.animation = "idle"


	# -------------------------
	# Jump
	# -------------------------

	if Input.is_action_just_pressed("blue-jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	# -------------------------
	# Movement
	# -------------------------

	var direction := Input.get_axis("blue-left", "blue-right")

	var current_speed := SPEED

	if is_ghosting:
		current_speed *= GHOST_SPEED_MULTIPLIER

	if direction:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)


	move_and_slide()
