@tool
extends Node2D

class_name Transition

@export var NextLevel:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var direction:Vector2 = Vector2.ZERO
var target_position:Vector2 = Vector2.ZERO

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		return
		
	var new_x = round(position.x / Player.TILE_SIZE) * Player.TILE_SIZE
	var new_y = round(position.y / Player.TILE_SIZE) * Player.TILE_SIZE
	position = lerp(position, Vector2(new_x, new_y), delta*15)

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("_on_area_2d_area_entered")
	if area.is_in_group("PlayerCat"):
		if NextLevel:
			$TransitionTimer.start()
	pass # Replace with function body.


func _on_transition_timer_timeout() -> void:
	get_tree().change_scene_to_file(NextLevel)
	pass # Replace with function body.
