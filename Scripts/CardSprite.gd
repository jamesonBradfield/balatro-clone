class_name CardSprite
extends Sprite2D

var selected: bool = false
var resource: Card


# We call this once right after instantiating the sprite
func setup(card_data: Card) -> void:
	resource = card_data
	texture = resource.atlas  #
	update_visuals()


func toggle_selection() -> void:
	selected = !selected
	update_visuals()


func update_visuals() -> void:
	if selected:
		modulate = Color(1.2, 1.2, 1.2)  # Highlight
	else:
		modulate = Color(1.0, 1.0, 1.0)  # Reset color
