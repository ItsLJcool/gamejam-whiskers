extends Node2D

@export var IntroScene:String

# TODO: MAIN MENU BG MUSIC!!!
@export var test:AudioStream

var original_pos:Vector2 = Vector2.ZERO
func _ready() -> void:
	$"Wiskers bruh".modulate.a = 0
	original_pos = $"Wiskers bruh".position
	pass # Replace with function body.


var mouse_select:bool = false
func _process(delta: float) -> void:
	if $Intro.is_stopped():
		$"Wiskers bruh".modulate.a = lerp($"Wiskers bruh".modulate.a, 1.0, delta*2)
	
	if mouse_select:
		$"Wiskers bruh/ColorRect".color.a = lerp($"Wiskers bruh/ColorRect".color.a, 1.0, delta*8)
	else:
		$"Wiskers bruh/ColorRect".color.a = lerp($"Wiskers bruh/ColorRect".color.a, 0.0, delta*8)
		
	if select:
		$ColorRect.color.a = lerp($ColorRect.color.a, 1.0, delta*3)
	
	if $ColorRect.color.a > 0.95:
		get_tree().change_scene_to_file(IntroScene)
		
	$"Wiskers bruh".position.y = original_pos.y + sin(float(Time.get_ticks_msec()) / 500) * 10
	pass

func _on_area_2d_mouse_entered() -> void:
	print("_on_area_2d_mouse_entered")
	mouse_select = true
	pass # Replace with function body.

var select:bool = false
func _on_area_2d_mouse_exited() -> void:
	print("_on_area_2d_mouse_exited")
	mouse_select = false
	pass # Replace with function body.
	
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and mouse_select and $"Wiskers bruh".modulate.a > 0.9:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			select = true
	pass # Replace with function body.
