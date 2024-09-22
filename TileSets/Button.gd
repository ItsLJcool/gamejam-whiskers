@tool
extends Node2D

class_name ButtonCustom

@export var sfx:AudioStream

var sfx_player:AudioStreamPlayer = AudioStreamPlayer.new()

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
	if button != null:
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
	
	all = []
	all = get_all(get_tree().root)
	init_button()
	
	sfx_player.stream = sfx
	add_child(sfx_player)
	var root = get_tree().root
	var player = Player.find_player_cat(root)
	if player:
		player.connect("player_moved", _on_player_moved)
		player.connect("force_complete_movements", _force_complete_movements)
	
	target_position = position
	prev_target_position = target_position

var move_speed:int = 15;
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		var new_x = round(position.x / Player.TILE_SIZE) * Player.TILE_SIZE
		var new_y = round(position.y / Player.TILE_SIZE) * Player.TILE_SIZE
		position = lerp(position, Vector2(new_x, new_y), delta * move_speed)
		return
		
	position = lerp(position, target_position, delta * move_speed)

func _on_player_moved(dir):
	if _overridePlayer:
		return
	for yarn in Yarn.all:
		if not is_instance_valid(yarn):
			continue
		if yarn.GRID_POSITION == GRID_POSITION and yarn.ColorType == ColorType and !pushed:
			pushed = true
			break
	pass
	
func _force_complete_movements():
	pass

var pushed:bool = false:
	set(value):
		var prev = pushed
		pushed = value
		print("button push: ", value)
		if prev != pushed:
			sfx_player.play()
		button.texture = button_sprite if !pushed else button_pushed
		button_toggled.emit(pushed)


var _overridePlayer:bool = false;
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerCat"):
		var cat = area.get_parent();
		if cat.CAT_TYPE == ColorType:
			_overridePlayer = true;
			pushed = true
	pass # Replace with function body.


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("PlayerCat"):
		var cat = area.get_parent();
		if cat.CAT_TYPE == ColorType:
			_overridePlayer = false;
			pushed = false
	pass # Replace with function body.
