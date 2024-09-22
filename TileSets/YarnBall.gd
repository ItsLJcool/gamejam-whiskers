@tool
extends Sprite2D

class_name Yarn

func get_all(node):
	var data:Array = [];
	if node is Yarn:
		data.push_back(node)
	for child in node.get_children():
		for n in get_all(child):
			data.push_back(n)
	return data;

static var all:Array = []

@export var ColorType:Player.Type = Player.Type.Yellow:
	set(value):
		ColorType = value;
		init_yarn();

var move_speed:int = 15;
var ice_speed:int = 5;

var target_position:Vector2 = Vector2.ZERO:
	set(value):
		target_position = value;
		if Wall != null:
			GRID_POSITION = Wall.local_to_map(Wall.to_local(target_position))
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

var is_moving:bool = false
func _ready():
	all = []
	all = get_all(get_tree().root)
	if not Engine.is_editor_hint():
		var root = get_tree().root
		var player = Player.find_player_cat(root)
		if player:
			player.connect("player_moved", _on_player_moved)
			player.connect("force_complete_movements", _force_complete_movements)
	
	target_position = position
	prev_target_position = target_position

var mult_speed = move_speed
func _process(delta):
	if Engine.is_editor_hint():
		var new_x = round(position.x / Player.TILE_SIZE) * Player.TILE_SIZE
		var new_y = round(position.y / Player.TILE_SIZE) * Player.TILE_SIZE
		position = lerp(position, Vector2(new_x, new_y), delta*move_speed)
		return
	
	if is_moving:
		position = lerp(position, target_position, delta*mult_speed)
		
	if position == target_position:
		is_moving = false

func _force_complete_movements():
	position = target_position

func move(direction, properties:Array = [
	Player.MoveProperties.ALLOW_SLIDING, Player.MoveProperties.CHECK_TILE_MAP
	]):
	_last_direction = direction
	prev_target_position = target_position
	target_position += direction * Player.TILE_SIZE
	is_moving = true

	if properties.has(Player.MoveProperties.CHECK_TILE_MAP):
		tile_map(Wall, properties)

func _on_player_moved(dir):
	for yarn in Yarn.all:
		if not is_instance_valid(yarn):
			continue
		if yarn == self:
			continue
		if yarn.GRID_POSITION == GRID_POSITION and yarn.ColorType == ColorType:
			move(dir, [Player.MoveProperties.CHECK_TILE_MAP])
			#_on_player_moved(dir)
		pass
	pass

var CAN_MOVE:bool = true;
func tile_map(TileMapThingy, properties:Array):
	if TileMapThingy == null:
		return;
	
	var customData = TileMapThingy.get_cell_tile_data(GRID_POSITION)
	var next_customData = TileMapThingy.get_cell_tile_data(GRID_POSITION + _last_direction)
	if customData:
		
		var allowed_walk = customData.get_custom_data("CatType") == ColorType
		if not allowed_walk:
			CAN_MOVE = false
			move(-_last_direction, [])
		else:
			CAN_MOVE = true
		
		if customData.get_custom_data("Slippery") and properties.has(Player.MoveProperties.ALLOW_SLIDING) and $IceSlideTimer.is_stopped():
			move(_last_direction)
