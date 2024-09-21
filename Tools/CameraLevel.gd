@tool
extends Node2D
@onready var _camera:Camera2D = $CameraLevel
@export var Zoom:float = 0.5:
	set(value):
		Zoom = value;
		if _camera:
			_camera.zoom = Vector2(Zoom, Zoom)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Zoom = Zoom
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var new_x = round(position.x / Player.TILE_SIZE) * Player.TILE_SIZE
	var new_y = round(position.y / Player.TILE_SIZE) * Player.TILE_SIZE
	position = lerp(position, Vector2(new_x, new_y), delta*5)
	pass
