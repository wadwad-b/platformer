extends Control

@export var player: CharacterBody2D

@onready var ghost_icon: TextureProgressBar = $GhostIcon
@onready var timer_label: Label = $TimerLabel


func _process(_delta: float) -> void:
	if player == null:
		return

	# Ghost Boost is active
	if player.is_ghosting:
		timer_label.text = "%.1fs" % player.ghost_timer

		# Drain from 100% to 0% during the 5 second boost
		var remaining_percent = player.ghost_timer / player.GHOST_DURATION
		ghost_icon.value = remaining_percent * 100.0

	# Ghost Boost is cooling down
	elif player.ghost_cooldown_timer > 0.0:
		timer_label.text = "%.1fs" % player.ghost_cooldown_timer

		# Fill from 0% to 100% during the 10 second cooldown
		var recharge_percent = 1.0 - (
			player.ghost_cooldown_timer / player.GHOST_COOLDOWN
		)

		ghost_icon.value = recharge_percent * 100.0

	# Ghost Boost is ready
	else:
		timer_label.text = ""
		ghost_icon.value = 100.0
