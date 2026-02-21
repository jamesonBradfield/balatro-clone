class_name Hand
extends Node2D

## cards in hand.
@export var cards: Array[Card]
## defines how much of the screen our hand covers.
@export_range(0, 100) var screen_coverage_percentage: int = 50
## Spacing constraints
@export var max_spacing: float = 100.0
@export var min_spacing: float = 10.0

var screen_size: Vector2
var total_hand_width: float
var selected_card_indices: Array[int] = []


func _ready() -> void:
	_update_screen_size()
	# Ensure the hand re-draws when the window is resized
	get_viewport().size_changed.connect(_on_viewport_resized)
	_fan_out_cards()


func _on_viewport_resized() -> void:
	_update_screen_size()
	_fan_out_cards()


func _update_screen_size() -> void:
	screen_size = get_viewport_rect().size
	# Center the node at the bottom of the screen
	global_position = Vector2(screen_size.x / 2.0, screen_size.y)
	total_hand_width = screen_size.x * (screen_coverage_percentage / 100.0)


func _draw_card(card: Card) -> void:
	cards.append(card)
	_fan_out_cards()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_process_click(event.position)


func _process_click(mouse_pos: Vector2) -> void:
	var children = get_children()
	# Iterate backwards to catch the "top-most" card in overlaps
	for i in range(children.size() - 1, -1, -1):
		var sprite = children[i] as Sprite2D
		if sprite and sprite.get_rect().has_point(sprite.to_local(mouse_pos)):
			_toggle_selection(i)
			return


func _toggle_selection(index: int) -> void:
	if selected_card_indices.has(index):
		selected_card_indices.erase(index)
	else:
		selected_card_indices.append(index)

	var data = cards[index]
	print(
		(
			"Hand: Card at index %d toggled. (%s of %s)"
			% [index, data.value + 1, Card.SUIT.keys()[data.suit]]
		)
	)
	_fan_out_cards()


func _fan_out_cards() -> void:
	for child in get_children():
		child.queue_free()

	if cards.is_empty():
		return

	# 1. Calculate spacing interval
	var count = cards.size()
	var interval = total_hand_width / (count - 1) if count > 1 else 0.0
	interval = clamp(interval, min_spacing, max_spacing)

	# 2. Calculate the total width to find the starting X offset
	var current_hand_width = interval * (count - 1)
	var start_x = -(current_hand_width / 2.0)

	# 3. Create sprites
	for i in range(count):
		_create_card_visual(i, start_x + (interval * i))


func _create_card_visual(index: int, x_pos: float) -> void:
	var sprite = Sprite2D.new()
	sprite.texture = cards[index].atlas
	add_child(sprite)

	var y_pos = -32  # Default "in hand" height

	if selected_card_indices.has(index):
		y_pos = -64  # "Lifted" height for selection
		sprite.modulate = Color(1.2, 1.2, 1.2)  # Highlight

	sprite.position = Vector2(x_pos, y_pos)


# --- Sorting Logic ---


func sort_by_value() -> void:
	_sort_cards(func(a, b): return a.value < b.value)


func sort_by_suit() -> void:
	_sort_cards(func(a, b): return a.suit < b.suit)


func _sort_cards(comparator: Callable) -> void:
	if cards.is_empty():
		return
	cards.sort_custom(comparator)
	selected_card_indices.clear()  # Reset selection to prevent index desync
	_fan_out_cards()
