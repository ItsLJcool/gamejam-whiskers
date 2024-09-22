@tool
extends Node2D

class_name Booster

func get_all(node):
	var data:Array = [];
	if node is Booster:
		data.push_back(node)
	for child in node.get_children():
		for n in get_all(child):
			data.push_back(n)
	return data;

static var all:Array = []

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

var Wall:TileMapLayer:
	get:
		return Player.Wall

var target_position:Vector2 = Vector2.ZERO:
	set(value):
		target_position = value;
		if Wall != null:
			GRID_POSITION = Wall.local_to_map(Wall.to_local(target_position))

var prev_target_position:Vector2 = Vector2.ZERO

var GRID_POSITION:Vector2 = Vector2.ZERO

func _ready() -> void:
	
	all = []
	all = get_all(get_tree().root)
	init_booster()
	dir_booster()
	if not Engine.is_editor_hint():
		var root = get_tree().root
		var player = Player.find_player_cat(root)
		if player:
			player.connect("player_moved", _on_player_moved)
			player.connect("force_complete_movements", _force_complete_movements)
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
	for cat in Player.all:
		if not is_instance_valid(cat):
			continue
		if cat.GRID_POSITION == GRID_POSITION and cat.CAT_TYPE == ColorType:
			print("MOVE PUSSY")
			cat.move(dir_to_vector()*2)
	for yarn in Yarn.all:
		if not is_instance_valid(yarn):
			continue
		if yarn.GRID_POSITION == GRID_POSITION and yarn.ColorType == ColorType:
			yarn.move(dir_to_vector()*2)
	pass
	
func _force_complete_movements():
	pass
