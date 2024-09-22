extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("SWITCH_TYPE"):
		switch_cat()

func switch_cat():
		print("Pressed Type")
		match Player.CURRENT_CAT:
			Player.Type.Yellow:
				Player.CURRENT_CAT = Player.Type.Cyan
			Player.Type.Cyan:
				Player.CURRENT_CAT = Player.Type.Red
			Player.Type.Red:
				Player.CURRENT_CAT = Player.Type.Pink
			Player.Type.Pink:
				Player.CURRENT_CAT = Player.Type.Yellow
		var isAvalColor:bool = false
		for cat in Player.all:
			if cat.CAT_TYPE == Player.CURRENT_CAT:
				isAvalColor = true;
				break
		if not isAvalColor:
			switch_cat()
