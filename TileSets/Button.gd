@tool
extends Node2D

class_name ButtonCustom

func get_all(node):
	var data:Array = [];
	if node is ButtonCustom:
		data.push_back(node)
	for child in node.get_children():
		for n in get_all(child):
			data.push_back(n)
	return data;

static var all:Array = []

signal button_toggled(pushed:bool)

@export var ColorType:Player.Type = Player.Type.Yellow:
	set(value):
		ColorType = value;
		init_button();

@export var button_sprite:Texture
@export var button_pushed:Texture

func init_button():
	button.material.set_shader_parameter("r", Player.COLOR_TYPES.get(Player.type_to_string(ColorType)))

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

@onready var button:Sprite2D = $Sprite2D

func _ready() -> void:
	all = get_all(get_tree().root)
	init_button()
	var root = get_tree().root
	var player = find_player_cat(root)
	if player:
		player.connect("player_moved", _on_player_moved)
		player.connect("force_complete_movements", _force_complete_movements)
	
	target_position = position
	prev_target_position = target_position

func find_player_cat(node):
	if node is Player:
		return node
	for child in node.get_children():
		var result = find_player_cat(child)
		if result:
			return result
	return null

var move_speed:int = 15;
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		var new_x = round(position.x / Player.TILE_SIZE) * Player.TILE_SIZE
		var new_y = round(position.y / Player.TILE_SIZE) * Player.TILE_SIZE
		position = lerp(position, Vector2(new_x, new_y), delta * move_speed)
		return
		
	position = lerp(position, target_position, delta * move_speed)

func _on_player_moved(dir):
	print("_on_player_moved BUTTON: ", GRID_POSITION)
	print("pushed: ", pushed)
	for cat in Player.all:
		if cat.GRID_POSITION == GRID_POSITION and cat.CAT_TYPE == ColorType:
			pushed = true
			return
		else:
			pushed = false
	
	for yarn in Yarn.all:
		if yarn.GRID_POSITION == GRID_POSITION and yarn.ColorType == ColorType:
			pushed = true
			return
		else:
			pushed = false
	pass
	
func _force_complete_movements():
	pass

var pushed:bool = false:
	set(value):
		pushed = value
		button.texture = button_sprite if !pushed else button_pushed
		button_toggled.emit(pushed)
