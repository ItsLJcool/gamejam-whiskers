@tool
extends Sprite2D

class_name Doors

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
		$Area2D/CollisionShape2D.set_deferred("disabled", _disabled)
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

var target_position:Vector2 = Vector2.ZERO
var prev_target_position:Vector2 = Vector2.ZERO

func _ready() -> void:
	if ButtonReference:
		ButtonReference.connect("button_toggled", button_toggled)
	init_door()
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
	pass

func _force_complete_movements():
	pass

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerCat") or area.is_in_group("Movable"):
		var theObject = area.get_parent()
		theObject.target_position = theObject.prev_target_position
		theObject.position = theObject.target_position
	pass # Replace with function body.

func button_toggled(pushed:bool):
	if pushed:
		if door_state == DoorType.Closed:
			door_state = DoorType.Opened
	else:
		if door_state == DoorType.Opened:
			door_state = DoorType.Closed
	pass
