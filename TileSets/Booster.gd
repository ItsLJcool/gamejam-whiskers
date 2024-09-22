@tool
extends Node2D

class_name Booster

enum Direction {
	LEFT = 0,
	DOWN = 1,
	UP = 2,
	RIGHT = 3,
}

func dir_to_vector(dir:Direction = BOOSTER_DIRECTION):
	match BOOSTER_DIRECTION:
		Direction.LEFT:
			return Vector2.LEFT
		Direction.DOWN:
			return Vector2.DOWN
		Direction.UP:
			return Vector2.UP
		Direction.RIGHT:
			return Vector2.RIGHT

@onready var BoosterSpr:AnimatedSprite2D = $AnimatedSprite2D

@export var ColorType:Player.Type = Player.Type.Yellow:
	set(value):
		ColorType = value;
		init_booster();

@export var BOOSTER_DIRECTION:Direction = Direction.RIGHT:
	set(value):
		BOOSTER_DIRECTION = value
		if BoosterSpr:
			dir_booster()

func dir_booster():
		match BOOSTER_DIRECTION:
			Direction.LEFT:
				BoosterSpr.rotation_degrees = 180
			Direction.DOWN:
				BoosterSpr.rotation_degrees = 90
			Direction.UP:
				BoosterSpr.rotation_degrees = -90
			Direction.RIGHT:
				BoosterSpr.rotation_degrees = 0

func init_booster():
	if BoosterSpr != null:
		BoosterSpr.material.set_shader_parameter("r", Player.COLOR_TYPES.get(Player.type_to_string(ColorType)))

var target_position:Vector2 = Vector2.ZERO
var prev_target_position:Vector2 = Vector2.ZERO

func _ready() -> void:
	init_booster()
	dir_booster()
	target_position = position
	prev_target_position = target_position
	pass # Replace with function body.

var move_speed:int = 15;
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		var new_x = round(position.x / Player.TILE_SIZE) * Player.TILE_SIZE
		var new_y = round(position.y / Player.TILE_SIZE) * Player.TILE_SIZE
		position = lerp(position, Vector2(new_x, new_y), delta * move_speed)
		return
		
	position = lerp(position, target_position, delta * move_speed)

func _on_player_moved(dir):
	pass
	
func _force_complete_movements():
	pass

func _on_area_2d_area_entered(area: Area2D) -> void:
	if (area.is_in_group("PlayerCat") and Player.CURRENT_CAT == ColorType) or (area.is_in_group("Movable") and area.get_parent().ColorType == ColorType):
		await get_tree().create_timer($Delay.wait_time).timeout
		var theObject = area.get_parent()
		theObject.move(dir_to_vector()*2)
		
	pass # Replace with function body.
