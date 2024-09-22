@tool
extends Node2D

class_name Player

enum Type {
	Yellow = 0,
	Cyan = 1,
	Red = 2,
	Pink = 3, #Pinkj... lol
}

static func find_player_cat(node):
	if node is Player:
		return node
	for child in node.get_children():
		var result = find_player_cat(child)
		if result:
			return result
	return null

func get_all(node):
	var data:Array = [];
	if node is Player:
		data.push_back(node)
	for child in node.get_children():
		for n in get_all(child):
			data.push_back(n)
	return data;

static var all:Array = []

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

var target_position:Vector2 = Vector2.ZERO:
	set(value):
		target_position = value;
		if Wall != null:
			GRID_POSITION = Wall.local_to_map(Wall.to_local(target_position))
var prev_target_position:Vector2 = Vector2.ZERO

var CAN_INPUT:bool = true

var is_moving:bool = false

func _ready():
	all = []
	all = get_all(get_tree().root)
	
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
		position = lerp(position, target_position, delta*mult_speed)
		move(Vector2.ZERO)
		return
		
	if Input.is_action_just_pressed("Player_Right") or Input.is_action_just_pressed("Player_Left") or Input.is_action_just_pressed("Player_Down") or Input.is_action_just_pressed("Player_Up"):
		position = target_position
		is_moving = false
		force_complete_movements.emit()
		move(get_direction_from_input())
	if is_moving:
		position = lerp(position, target_position, delta*mult_speed)
		
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

enum MoveProperties {
	ALLOW_SLIDING,
	CHECK_TILE_MAP,
	FLIP,
	CHECK_OVERLAP,
}
 
func move(direction, properties:Array = [
	Player.MoveProperties.ALLOW_SLIDING, Player.MoveProperties.CHECK_TILE_MAP, Player.MoveProperties.FLIP,
	Player.MoveProperties.CHECK_OVERLAP
	]):
	if properties.has(MoveProperties.FLIP):
		if direction.x != 0:
			FLIPPED = true if direction.x < 0 else false
	_last_direction = direction
	prev_target_position = target_position
	target_position += direction * tile_size
	is_moving = true
	
	if properties.has(MoveProperties.CHECK_OVERLAP):
		check_overlaps()
	player_moved.emit(direction)
	if properties.has(MoveProperties.CHECK_TILE_MAP):
		tile_map(Wall, properties)

func check_overlaps():
	for cat in Player.all:
		if not is_instance_valid(cat) or cat == self:
			continue
		if cat.GRID_POSITION == GRID_POSITION:
			move(-_last_direction)
	for yarn in Yarn.all:
		if not is_instance_valid(yarn):
			continue
		if yarn.GRID_POSITION == GRID_POSITION and yarn.ColorType == CAT_TYPE:
			$IceSlideTimer.start()
			yarn.move(_last_direction)
			if !yarn.CAN_MOVE:
				move(-_last_direction, [])
	
	for booster in Booster.all:
		if not is_instance_valid(booster):
			continue
		if booster.GRID_POSITION == GRID_POSITION and booster.ColorType == CAT_TYPE:
			move(booster.dir_to_vector()*2)
			
	for door in Doors.all:
		if not is_instance_valid(door):
			continue
		if door.GRID_POSITION == GRID_POSITION and door.ColorType == CAT_TYPE and door.door_state != Doors.DoorType.Opened:
			move(-_last_direction, [])

var CAN_MOVE:bool = true;
func tile_map(TileMapThingy, properties):
	if TileMapThingy == null:
		return;
	
	var customData = TileMapThingy.get_cell_tile_data(GRID_POSITION)
	var next_customData = TileMapThingy.get_cell_tile_data(GRID_POSITION + _last_direction)
	if customData:
		var allowed_walk = customData.get_custom_data("CatType") == CAT_TYPE or CAT_TYPE < 0
		if not allowed_walk:
			CAN_MOVE = false
			move(-_last_direction, [Player.MoveProperties.CHECK_OVERLAP])
		else:
			CAN_MOVE = true
		
		if customData.get_custom_data("Slippery") and properties.has(MoveProperties.ALLOW_SLIDING) and $IceSlideTimer.is_stopped():
			move(_last_direction)
		
