extends Area2D

@export_enum("blue", "red") var goal_owner: String = "blue"

var already_scored: bool = false


func _on_body_entered(body: Node2D) -> void:
	if already_scored:
		return

	if body.name != "Ball":
		return

	already_scored = true

	var game = get_tree().current_scene

	if goal_owner == "blue":
		game.red_scored()
	else:
		game.blue_scored()


func reset_goal() -> void:
	already_scored = false
