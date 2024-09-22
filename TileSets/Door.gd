@tool
extends Sprite2D

class_name Doors

func get_all(node):
	var data:Array = [];
	if node is Doors:
		data.push_back(node)
	for child in node.get_children():
		for n in get_all(child):
			data.push_back(n)
	return data;

static var all:Array = []

enum DoorType {
	Closed = 0,
	Locked = 1,
	Opened = 2,
}

@export var ColorType:Player.Type = Player.Type.Yellow:
	set(value):
		ColorType = value;
		init_door();

@export var closed_door:Texture
@export var locked_door:Texture
@export var opened_door:Texture

@export var door_state:DoorType = DoorType.Closed:
	set(value):
		door_state = value
		var _disabled = true if door_state == DoorType.Opened else false
		match door_state:
			DoorType.Opened:
				texture = opened_door
			DoorType.Locked:
				texture = locked_door
			_:
				texture = closed_door

@export var ButtonReference:ButtonCustom

func init_door():
	material.set_shader_parameter("r", Player.COLOR_TYPES.get(Player.type_to_string(ColorType)))

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
	
	if ButtonReference:
		ButtonReference.connect("button_toggled", button_toggled)
	init_door()
	var player = Player.find_player_cat(get_tree().root)
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
	for yarn in Yarn.all:
		if not is_instance_valid(yarn):
			continue
		if yarn.GRID_POSITION == GRID_POSITION and yarn.ColorType == ColorType and door_state != DoorType.Opened:
			yarn.move(-dir, [
			Player.MoveProperties.ALLOW_SLIDING,Player.MoveProperties.CHECK_TILE_MAP
			])
	pass

func _force_complete_movements():
	pass

func button_toggled(pushed:bool):
	if pushed:
		if door_state == DoorType.Closed:
			door_state = DoorType.Opened
	else:
		if door_state == DoorType.Opened:
			door_state = DoorType.Closed
	pass
