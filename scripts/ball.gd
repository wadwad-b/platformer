extends CharacterBody2D

@onready var hitbox: Area2D = $Hitbox

@export var gravity: float = 1200.0
@export var bounce_strength: float = 750.0
@export var ground_friction: float = 10000.0
@export var hit_strength: float = 1.5

var was_touching: bool = false
var was_on_floor: bool = false
var is_frozen: bool = false

var ground_bounce_sound: AudioStreamPlayer
var player_hit_sound: AudioStreamPlayer


func _ready() -> void:
	# Create the ground bounce sound player
	ground_bounce_sound = AudioStreamPlayer.new()
	ground_bounce_sound.stream = load("res://assets/audio/bounce.mp3")
	add_child(ground_bounce_sound)

	# Create the player hit sound player
	player_hit_sound = AudioStreamPlayer.new()
	player_hit_sound.stream = load("res://assets/audio/bounce2.mp3")
	player_hit_sound.volume_db = 25
	add_child(player_hit_sound)


func _physics_process(delta: float) -> void:
	if is_frozen:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

	# Bounce off the ground
	if is_on_floor() and velocity.y >= 0:
		velocity.y = -bounce_strength

		# Only play the sound when the ball actually lands
		if not was_on_floor:
			ground_bounce_sound.play()

	if is_on_floor():
		velocity.x = move_toward(
			velocity.x,
			0,
			ground_friction * delta
		)

	# Check if the ball is touching a player
	var is_touching := false

	for body in hitbox.get_overlapping_bodies():
		if body is CharacterBody2D:
			if body.get("is_ghosting") == true:
				continue

			is_touching = true
			break

	# Play player collision sound when contact begins
	if is_touching and not was_touching:
		for body in hitbox.get_overlapping_bodies():
			if body is CharacterBody2D:
				if body.get("is_ghosting") == true:
					continue

				if abs(body.velocity.x) > 10:
					velocity.x = body.velocity.x * hit_strength
				else:
					velocity.x = -velocity.x * 0.5

				player_hit_sound.play()

				break

	was_touching = is_touching
	was_on_floor = is_on_floor()


func freeze_ball() -> void:
	is_frozen = true
	velocity = Vector2.ZERO


func reset_ball(position: Vector2) -> void:
	global_position = position
	velocity = Vector2.ZERO
	was_touching = false
	was_on_floor = false
	is_frozen = false
