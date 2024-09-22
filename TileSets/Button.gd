@tool
extends Node2D

class_name ButtonCustom

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

var target_position:Vector2 = Vector2.ZERO
var prev_target_position:Vector2 = Vector2.ZERO

@onready var button:Sprite2D = $Sprite2D

func _ready() -> void:
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
	pass
	
func _force_complete_movements():
	pass

var pushed:bool = false:
	set(value):
		pushed = value
		button.texture = button_sprite if !pushed else button_pushed
		button_toggled.emit(pushed)

func _on_area_2d_area_entered(area: Area2D) -> void:
	print("button _on_area_2d_area_entered")
	if (area.is_in_group("PlayerCat") and Player.CURRENT_CAT == ColorType) or (area.is_in_group("Movable") and area.get_parent().ColorType == ColorType):
		pushed = true
	pass # Replace with function body.

func _on_area_2d_area_exited(area: Area2D) -> void:
	print("button _on_area_2d_area_exited")
	if (area.is_in_group("PlayerCat") and Player.CURRENT_CAT == ColorType) or (area.is_in_group("Movable") and area.get_parent().ColorType == ColorType):
		pushed = false
	pass # Replace with function body.
