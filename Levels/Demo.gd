extends Node2D

@export var ToMainMenu:String
@export var Speed:int = 65

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


var toMainMenu:bool = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$RichTextLabel.position.y -= Speed*delta
	if toMainMenu:
		$ColorRect.color.a = lerp($ColorRect.color.a, 1.0, delta*3)
		
	if $ColorRect.color.a > 0.95:
		get_tree().change_scene_to_file(ToMainMenu)


func _on_area_2d_area_entered(area: Area2D) -> void:
	toMainMenu = true
	pass # Replace with function body.
