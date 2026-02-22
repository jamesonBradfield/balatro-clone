class_name CardSprite
extends Sprite2D

signal selection_toggled(card: CardSprite)

var selected: bool = false
var resource: Card


func _ready() -> void:
	texture = resource.atlas
	update_visuals()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if get_rect().has_point(to_local(event.position)):
			toggle_selection()
			get_viewport().set_input_as_handled()


func toggle_selection() -> void:
	selected = !selected
	update_visuals()
	selection_toggled.emit(self)


func update_visuals() -> void:
	modulate = Color(1.2, 1.2, 1.2) if selected else Color(1.0, 1.0, 1.0)
	position.y = -64 if selected else -32
