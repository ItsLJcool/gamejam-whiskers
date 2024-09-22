@tool
extends Node2D

class_name Player

enum Type {
	Yellow = 0,
	Cyan = 1,
	Red = 2,
	Pink = 3, #Pinkj... lol
}

signal player_moved(direction:Vector2)
signal force_complete_movements()

static var COLOR_TYPES:Dictionary = {
	"Yellow": Color(0.875, 0.592, 0.149), #df9726
	"Cyan": Color(0.094, 0.773, 0.804), #18c5cd
	"Red": Color(0.827, 0, 0), #d30000
	"Pink": Color(0.882, 0, 0.537), #e10089
}

static func type_to_string(cat:Type = Type.Yellow):
	return Type.keys()[cat].capitalize()

@onready var cat_sprite:Sprite2D = $CatSprite
@onready var movement_delay:Timer = $MovementDelay
var cat_image_file:String = "res://Assets/CatMax/%s_Cat.png"

@export var CAT_TYPE:Type = Type.Yellow:
	set(value):
		CAT_TYPE = value
		if cat_sprite:
			init_cat();
		
func init_cat():
	cat_sprite.texture = load(cat_image_file % type_to_string(CAT_TYPE))

@export var _wall:TileMapLayer:
	set(value):
		_wall = value
		Wall = value
	get:
		if Wall == _wall:
			return Wall
		else:
			return _wall
static var Wall:TileMapLayer

@export var _topLayer:TileMapLayer:
	set(value):
		_topLayer = value
		TopLayer = value
	get:
		if TopLayer == _topLayer:
			return TopLayer
		else:
			return _topLayer
static var TopLayer:TileMapLayer

static var CURRENT_CAT:Type = Type.Yellow

@export var tile_size = 128:
	set(value):
		tile_size = value;
		TILE_SIZE = value;
	get:
		return TILE_SIZE;

static var TILE_SIZE = 128;
@export var move_speed = 15
@export var ice_speed = 5

var GRID_POSITION:Vector2 = Vector2.ZERO;

var target_position:Vector2 = Vector2.ZERO
var prev_target_position:Vector2 = Vector2.ZERO

var CAN_INPUT:bool = true

var is_moving:bool = false

func _ready():
	init_cat()
	target_position = position
	if ON_SCENE_START_MOVE:
		move(_last_direction)
	
var FLIPPED = false:
	set(value):
		if cat_sprite.flip_h != value:
			FLIPPED = value
		cat_sprite.flip_h = value

#internal use
var mult_speed = move_speed
@export var _last_direction:Vector2 = Vector2.ZERO:
	set(value):
		_last_direction = value
		LAST_DIRECTION = value;
	get:
		if LAST_DIRECTION == _last_direction:
			return LAST_DIRECTION
		else:
			return _last_direction
@export var ON_SCENE_START_MOVE:bool = true

static var LAST_DIRECTION:Vector2 = Vector2.ZERO
func _process(delta):
	if Engine.is_editor_hint():
		var new_x = round(position.x / tile_size) * tile_size
		var new_y = round(position.y / tile_size) * tile_size
		position = lerp(position, Vector2(new_x, new_y), delta*move_speed)
		return
		
	if Input.is_action_just_pressed("Reset"):
		get_tree().reload_current_scene()
	
	if CAT_TYPE != CURRENT_CAT:
		return
		
	if Input.is_action_just_pressed("Player_Right") or Input.is_action_just_pressed("Player_Left") or Input.is_action_just_pressed("Player_Down") or Input.is_action_just_pressed("Player_Up"):
		if $MovementDelay.is_stopped():
			$MovementDelay.start()
			position = target_position
			is_moving = false
			force_complete_movements.emit()
			move(get_direction_from_input())
	
	if is_moving:
		position = move_towards_target(position, target_position, mult_speed)
		
	if position == target_position:
		is_moving = false

func get_direction_from_input() -> Vector2:
	if CAN_INPUT:
		if Input.is_action_just_pressed("Player_Right"):
			return Vector2(1, 0)
		elif Input.is_action_just_pressed("Player_Left"):
			return Vector2(-1, 0)
		elif Input.is_action_just_pressed("Player_Down"):
			return Vector2(0, 1)
		elif Input.is_action_just_pressed("Player_Up"):
			return Vector2(0, -1)
	return Vector2.ZERO

func move(direction: Vector2):
	if direction.x != 0:
		FLIPPED = true if direction.x < 0 else false
	_last_direction = direction
	prev_target_position = target_position
	target_position += direction * tile_size
	is_moving = true
	
	if Wall != null:
		GRID_POSITION = Wall.local_to_map(Wall.to_local(target_position))
	
	tile_map(Wall)
	player_moved.emit(direction)

func tile_map(TileMapThingy):
	if TileMapThingy == null:
		return;
	
	var customData = TileMapThingy.get_cell_tile_data(GRID_POSITION)
	var next_customData = TileMapThingy.get_cell_tile_data(GRID_POSITION + _last_direction)
	if customData:
		# For now, just stop the player from entering, they should respawn when they enter though.
		var allowed_walk = customData.get_custom_data("CatType") == CAT_TYPE or CAT_TYPE < 0
		if not allowed_walk:
			target_position = prev_target_position
		
		if customData.get_custom_data("Slippery"):
			move(_last_direction)

func move_towards_target(current_position: Vector2, target_position: Vector2, speed: float) -> Vector2:
	var direction = (target_position - current_position).normalized()
	var new_position = current_position + direction * speed
	if current_position.distance_to(target_position) < speed:
		new_position = target_position
	return new_position
