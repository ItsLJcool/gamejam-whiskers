@tool
extends Node2D

class_name Player

enum Type {
	Yellow = 0,
	Cyan = 1,
	Red = 2,
	Pink = 3, #Pinkj... lol
}

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

var move_back:bool = false

var CAN_INPUT:bool = true

func _ready():
	init_cat()
	target_position = position
	if ON_SCENE_START_MOVE:
		move_direction(_last_direction)
	
var FLIPPED = false
func flip_sprite(dir):
	if cat_sprite.flip_h != dir:
		FLIPPED = dir
	cat_sprite.flip_h = dir

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
	
	if CAT_TYPE != CURRENT_CAT:
		return
		
	var direction = Vector2()
	if movement_delay.is_stopped() and CAN_INPUT:
		if Input.is_action_just_pressed("Player_Right"):
			direction = Vector2(1, 0)
		elif Input.is_action_just_pressed("Player_Left"):
			direction = Vector2(-1, 0)
		elif Input.is_action_just_pressed("Player_Down"):
			direction = Vector2(0, 1)
		elif Input.is_action_just_pressed("Player_Up"):
			direction = Vector2(0, -1)
	if move_back:
		_last_direction = Vector2.ZERO
		target_position = prev_target_position
		position = lerp(position, target_position, delta*(move_speed*2))
		
	if direction != Vector2() and !move_back:
		movement_delay.start()
		move_direction(direction)
	
	if Wall != null:
		GRID_POSITION = Wall.local_to_map(Wall.to_local(target_position))
		GridLoops(Wall);
	if TopLayer != null:
		GridLoops(TopLayer);
	
	# Move smoothly towards the target position
	position = lerp(position, target_position, delta*mult_speed)
	
func GridLoops(TileMapThingy):
	var customData = TileMapThingy.get_cell_tile_data(GRID_POSITION)
	var next_customData = TileMapThingy.get_cell_tile_data(GRID_POSITION + _last_direction)
	if customData:
		# For now, just stop the player from entering, they should respawn when they enter though.
		var allowed_walk = customData.get_custom_data("CatType") == CAT_TYPE
		if not allowed_walk:
			prevent_move(_last_direction)
			return
			
		# ICE PHYSICS
		var next_allowed_walk = next_customData.get_custom_data("CatType") == CAT_TYPE if next_customData else true
		if customData.get_custom_data("Slippery") and next_allowed_walk and _last_direction != Vector2.ZERO:
			CAN_INPUT = false
			mult_speed = ice_speed
			if not next_customData:
				CAN_INPUT = true
			elif next_customData and $IceSlideTimer.is_stopped():
				$IceSlideTimer.start()
				move_direction(_last_direction)
		else:
			if not CAN_INPUT:
				CAN_INPUT = true
			mult_speed = move_speed
	
	
	
func move_direction(dir):
	flip_sprite(true if dir.x < 0 else false)
	prev_target_position = target_position
	_last_direction = dir
	target_position += dir * tile_size  # Move to the next tile

func prevent_move(direction):
	position += direction * move_speed
	target_position = prev_target_position

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerCat") or area.is_in_group("StopPlayer"):
		move_back = true
	
	

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerCat") or area.is_in_group("StopPlayer"):
		move_back = false
	if area.is_in_group("CameraViewFrame"):
		print("whoa")
