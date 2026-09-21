extends CharacterBody2D

@onready var hitbox: Area2D = $Hitbox

@export var gravity: float = 1200.0
@export var bounce_strength: float = 750.0
@export var ground_friction: float = 10000.0
@export var hit_strength: float = 1.5

var was_touching: bool = false
var is_frozen: bool = false


func _physics_process(delta: float) -> void:
	# Don't do anything while waiting for the reset
	if is_frozen:
		return

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Move the ball
	move_and_slide()

	# Bounce
	if is_on_floor() and velocity.y >= 0:
		velocity.y = -bounce_strength

	# Quickly stop horizontal movement on the ground
	if is_on_floor():
		velocity.x = move_toward(
			velocity.x,
			0,
			ground_friction * delta
		)

	# Check whether a non-ghost player is touching
	var is_touching := false

	for body in hitbox.get_overlapping_bodies():
		if body is CharacterBody2D:
			if body.get("is_ghosting") == true:
				continue

			is_touching = true
			break

	# Only react when we JUST started touching
	if is_touching and not was_touching:
		for body in hitbox.get_overlapping_bodies():
			if body is CharacterBody2D:
				if body.get("is_ghosting") == true:
					continue

				if abs(body.velocity.x) > 10:
					velocity.x = body.velocity.x * hit_strength
				else:
					velocity.x = -velocity.x * 0.5

				break

	# Save the current state
	was_touching = is_touching


func freeze_ball() -> void:
	is_frozen = true
	velocity = Vector2.ZERO


func reset_ball(position: Vector2) -> void:
	global_position = position
	velocity = Vector2.ZERO
	was_touching = false
	is_frozen = false
