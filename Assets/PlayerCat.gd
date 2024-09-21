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

func type_to_string(cat:Type = CAT_TYPE):
	return Type.keys()[cat].capitalize()

@onready var cat_sprite:Sprite2D = $CatSprite
var cat_image_file:String = "res://Assets/CatMax/%s_Cat.png"

@export var CAT_TYPE:Type = Type.Yellow:
	set(value):
		CAT_TYPE = value
		if cat_sprite:
			init_cat();
		
func init_cat():
	cat_sprite.texture = load(cat_image_file % type_to_string())

@export var Wall:TileMapLayer

static var CURRENT_CAT:Type = Type.Yellow

@export var tile_size = 128:
	set(value):
		tile_size = value;
		TILE_SIZE = value;
	get:
		return TILE_SIZE;

static var TILE_SIZE = 128;
var move_speed = 15

var GRID_POSITION:Vector2 = Vector2.ZERO;

var target_position = Vector2()
func _ready():
	init_cat()
	target_position = position
	
var FLIPPED = false
func flip_sprite(dir):
	if cat_sprite.flip_h != dir:
		FLIPPED = dir
	cat_sprite.flip_h = dir

func _process(delta):
	if Engine.is_editor_hint():
		var new_x = round(position.x / tile_size) * tile_size
		var new_y = round(position.y / tile_size) * tile_size
		position = lerp(position, Vector2(new_x, new_y), delta*move_speed)
		return
	if CAT_TYPE != CURRENT_CAT:
		return
	var direction = Vector2()
	if Input.is_action_just_pressed("Player_Right"):
		flip_sprite(false)
		direction = Vector2(1, 0)
	elif Input.is_action_just_pressed("Player_Left"):
		flip_sprite(true)
		direction = Vector2(-1, 0)
	elif Input.is_action_just_pressed("Player_Down"):
		direction = Vector2(0, 1)
	elif Input.is_action_just_pressed("Player_Up"):
		direction = Vector2(0, -1)
	
	if direction != Vector2():
		target_position += direction * tile_size  # Move to the next tile
	
	# Move smoothly towards the target position
	position = lerp(position, target_position, delta*move_speed)
	GRID_POSITION = Wall.local_to_map(Wall.to_local(target_position))
	var killMe = Wall.get_cell_tile_data(GRID_POSITION)
	if killMe:
		print(killMe.get_custom_data("CatType"));
	
