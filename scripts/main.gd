extends Node

@onready var blue_guy: CharacterBody2D = $"Blue Guy"
@onready var red_guy: CharacterBody2D = $"Red Guy"
@onready var ball: CharacterBody2D = $Ball
@onready var camera: Camera2D = $Camera2D
@onready var score_label: Label = $CanvasLayer/ScoreLabel

@onready var blue_goal: Area2D = $"Blue Goal/GoalDetector"
@onready var red_goal: Area2D = $"Red Goal/GoalDetector"

@export var edge_padding: float = 300.0
@export var min_zoom: float = 0.25
@export var max_zoom: float = 1.5
@export var camera_bottom_y: float = 1080.0

var blue_score: int = 0
var red_score: int = 0

var blue_start_position: Vector2
var red_start_position: Vector2
var ball_start_position: Vector2

var scoring_in_progress: bool = false

var goal_sound: AudioStreamPlayer


func _ready() -> void:
	# Create goal sound player
	goal_sound = AudioStreamPlayer.new()
	goal_sound.stream = load("res://assets/audio/wow.mp3")
	add_child(goal_sound)

	# Remember starting positions
	blue_start_position = blue_guy.global_position
	red_start_position = red_guy.global_position
	ball_start_position = ball.global_position

	update_scoreboard()

	camera.enabled = true
	camera.zoom = Vector2(1, 1)


func _process(_delta: float) -> void:
	var midpoint_x = (
		blue_guy.global_position.x +
		red_guy.global_position.x
	) / 2.0

	var player_distance = abs(
		blue_guy.global_position.x -
		red_guy.global_position.x
	)

	var viewport_width = get_viewport().get_visible_rect().size.x

	var required_width = player_distance + edge_padding * 2.0

	var required_zoom = viewport_width / required_width

	var current_zoom = clamp(
		required_zoom,
		min_zoom,
		max_zoom
	)

	camera.zoom = Vector2(current_zoom, current_zoom)

	var viewport_height = get_viewport().get_visible_rect().size.y
	var visible_height = viewport_height / current_zoom

	var camera_y = camera_bottom_y - visible_height / 2.0

	camera.global_position = Vector2(
		midpoint_x,
		camera_y
	)


func blue_scored() -> void:
	if scoring_in_progress:
		return

	scoring_in_progress = true

	blue_score += 1
	update_scoreboard()

	goal_sound.play()

	await reset_after_goal()


func red_scored() -> void:
	if scoring_in_progress:
		return

	scoring_in_progress = true

	red_score += 1
	update_scoreboard()

	goal_sound.play()

	await reset_after_goal()


func reset_after_goal() -> void:
	# Let physics continue for 3 seconds
	await get_tree().create_timer(3.0).timeout

	# Reset Blue Guy
	blue_guy.global_position = blue_start_position
	blue_guy.velocity = Vector2.ZERO

	# Reset Red Guy
	red_guy.global_position = red_start_position
	red_guy.velocity = Vector2.ZERO

	# Reset Ball
	ball.reset_ball(ball_start_position)

	# Reset both goals
	blue_goal.reset_goal()
	red_goal.reset_goal()

	# Allow another goal
	scoring_in_progress = false


func update_scoreboard() -> void:
	score_label.text = "%d     -     %d" % [blue_score, red_score]
