@tool
extends Sprite2D

class_name Yarn

@export var ColorType:Player.Type = Player.Type.Yellow:
	set(value):
		ColorType = value;
		init_yarn();

var move_speed:int = 15;
var ice_speed:int = 5;

var target_position:Vector2 = Vector2.ZERO
var prev_target_position:Vector2 = Vector2.ZERO

func init_yarn():
	material.set_shader_parameter("r", Player.COLOR_TYPES.get(Player.type_to_string(ColorType)))

# Called when the node enters the scene tree for the first time.
var direction:Vector2 = Vector2.ZERO
var _last_direction:Vector2 = Vector2.ZERO
func _ready() -> void:
	target_position = position
	pass # Replace with function body.

var Wall:TileMapLayer:
	get:
		return Player.Wall

var GRID_POSITION:Vector2 = Vector2.ZERO

@onready var yarnBox:CollisionShape2D = $"YarnArea/Yarn GD COLON!!!!"
@onready var stopPlayer:CollisionShape2D = $StopPlayer/StopPlayerMovement

static var BeingPushed:Sprite2D

var mult_speed = move_speed
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		var new_x = round(position.x / Player.TILE_SIZE) * Player.TILE_SIZE 
		var new_y = round(position.y / Player.TILE_SIZE) * Player.TILE_SIZE
		position = lerp(position, Vector2(new_x, new_y), delta*move_speed)
		return
	
	if direction != Vector2():
		move_direction(direction)
	
	GRID_POSITION = Wall.local_to_map(Wall.to_local(target_position))
	
	var customData = Wall.get_cell_tile_data(GRID_POSITION)
	var next_customData = Wall.get_cell_tile_data(GRID_POSITION + _last_direction)
	if customData:
		# For now, just stop the player from entering, they should respawn when they enter though.
		var allowed_walk = customData.get_custom_data("CatType") == ColorType
		if not allowed_walk:
			target_position = prev_target_position
			yarnBox.disabled = true
			stopPlayer.disabled = false
	
		# ICE PHYSICS
		var next_allowed_walk = next_customData.get_custom_data("CatType") == ColorType if next_customData else true
		if customData.get_custom_data("Slippery") and next_allowed_walk:
			mult_speed = ice_speed
			if next_customData and $IceSlideTimer.is_stopped():
				$IceSlideTimer.start()
				if next_customData.get_custom_data("Slippery"):
					move_direction(_last_direction)
				else:
					if _last_direction != Vector2.ZERO:
						move_direction(_last_direction)
						_last_direction = Vector2.ZERO
		else:
			mult_speed = move_speed
			
	direction = Vector2.ZERO
	position = lerp(position, target_position, delta*move_speed)

func move_direction(dir):
	_last_direction = dir
	prev_target_position = target_position
	target_position += dir * Player.TILE_SIZE  # Move to the next tile
	
func _on_yarn_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerCat"):
		move_direction(Player.LAST_DIRECTION)
		BeingPushed = self
		return
	if area.is_in_group("Yarn") and self != BeingPushed:
		move_direction(Player.LAST_DIRECTION)

func _on_stop_player_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerCat"):
		$Test.start()

func _on_test_timeout() -> void:
	yarnBox.disabled = false
	stopPlayer.disabled = true
