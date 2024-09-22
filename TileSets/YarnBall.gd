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

var Wall:TileMapLayer:
	get:
		return Player.Wall

var GRID_POSITION:Vector2 = Vector2.ZERO

@onready var yarnCollision:CollisionShape2D = $"YarnArea/Yarn GD COLON!!!!"
@onready var stopCollision:CollisionShape2D = $StopPlayer/StopPlayerMovement

var is_moving:bool = false
func _ready():
	var root = get_tree().root
	var player = find_player_cat(root)
	if player:
		player.connect("player_moved", _on_player_moved)
		player.connect("force_complete_movements", _force_complete_movements)
	
	target_position = position
	prev_target_position = target_position
	tile_map(Wall)

func find_player_cat(node):
	if node is Player:
		return node
	for child in node.get_children():
		var result = find_player_cat(child)
		if result:
			return result
	return null

var mult_speed = move_speed
func _process(delta):
	if Engine.is_editor_hint():
		var new_x = round(position.x / Player.TILE_SIZE) * Player.TILE_SIZE
		var new_y = round(position.y / Player.TILE_SIZE) * Player.TILE_SIZE
		position = lerp(position, Vector2(new_x, new_y), delta*move_speed)
		return
	
	if is_moving:
		position = move_towards_target(position, target_position, mult_speed)
		
	if position == target_position:
		is_moving = false

func _force_complete_movements():
	position = target_position

func move(dir):
	print("Yarn Move")
	_last_direction = dir
	prev_target_position = target_position
	target_position += dir * Player.TILE_SIZE
	is_moving = true
	tile_map(Wall)

func _on_player_moved(dir):
	pass
	#if not is_moving:
		#tile_map(Wall)
		#target_position += dir * Player.TILE_SIZE
		#is_moving = true

var stop_movement:bool = false:
	set(value):
		stop_movement = value
		yarnCollision.set_deferred("disabled", stop_movement)
		stopCollision.set_deferred("disabled", !stop_movement)

func tile_map(TileMapThingy):
	if TileMapThingy == null:
		return;
	
	GRID_POSITION = TileMapThingy.local_to_map(TileMapThingy.to_local(target_position))
	
	var customData = TileMapThingy.get_cell_tile_data(GRID_POSITION)
	var next_customData = TileMapThingy.get_cell_tile_data(GRID_POSITION + _last_direction)
	if customData:
		
		var allowed_walk = customData.get_custom_data("CatType") == ColorType
		if not allowed_walk:
			stop_movement = true
			target_position = prev_target_position
		
		if customData.get_custom_data("Slippery"):
			move(_last_direction)

func move_towards_target(current_position: Vector2, target_position: Vector2, speed: float) -> Vector2:
	var direction = (target_position - current_position).normalized()
	var new_position = current_position + direction * speed
	if current_position.distance_to(target_position) < speed:
		new_position = target_position
	return new_position

func _on_yarn_area_area_entered(area: Area2D) -> void:
	print("_on_yarn_area_area_entered")
	if area.is_in_group("PlayerCat"):
		move(Player.LAST_DIRECTION)
		
	if area.get_parent() is Yarn:
		if Wall != null:
			GRID_POSITION = Wall.local_to_map(Wall.to_local(target_position))
		print("area parent: ", area.get_parent().GRID_POSITION, " Yarn: ", GRID_POSITION)
		if area.get_parent().GRID_POSITION == GRID_POSITION:
			move(Player.LAST_DIRECTION)

func _on_stop_player_area_entered(area: Area2D) -> void:
	print("_on_stop_player_area_entered")
	if area.is_in_group("PlayerCat") or area.is_in_group("Movable"):
		var theObject = area.get_parent()
		if area.is_in_group("Movable"):
			theObject.stop_movement = true
		theObject.target_position = theObject.prev_target_position
		theObject.position = theObject.target_position
	pass # Replace with function body.

func _on_stop_player_area_exited(area: Area2D) -> void:
	stop_movement = false


func _on_test_timeout() -> void:
	stop_movement = false
	pass # Replace with function body.
