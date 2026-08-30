extends HBoxContainer
@export var speed: float = 100.0

func _ready() -> void:
	for child in get_children():
		if child is Control:
			child.offset_transform_enabled = true
			child.offset_transform_visual_only = true


func _process(delta: float) -> void:
	for child in get_children():
		child.offset_transform_position.x -= speed * delta

		if child.position.x + child.offset_transform_position.x + child.size.x < 0.0:
			var rightmost := 0.0

			for other in get_children():
				if other == child:
					continue

				var other_left : float = other.position.x + other.offset_transform_position.x
				var other_right : float = other_left + other.size.x
				rightmost = max(rightmost, other_right)

			if get_child_count() == 1: rightmost = size.x

			child.offset_transform_position.x = rightmost + get_theme_constant("separation") - child.position.x
