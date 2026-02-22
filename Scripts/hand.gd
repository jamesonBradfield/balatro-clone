class_name Hand
extends Node2D

@export_range(0, 100) var screen_coverage_percentage: int = 50  # [cite: 10]
@export var max_spacing: float = 100.0  # [cite: 10]
@export var min_spacing: float = 10.0  # [cite: 10]

var screen_size: Vector2
var total_hand_width: float
var sorting_by: SORTING
enum SORTING { VALUE, SUIT }


func _ready() -> void:
	_update_screen_size()
	get_viewport().size_changed.connect(_on_viewport_resized)


func _on_viewport_resized() -> void:
	_update_screen_size()
	_update_hand_layout()


func _update_screen_size() -> void:
	screen_size = get_viewport_rect().size
	# Center the node at the bottom of the screen
	global_position = Vector2(screen_size.x / 2.0, screen_size.y)
	total_hand_width = screen_size.x * (screen_coverage_percentage / 100.0)


func _draw_card(card: Card) -> void:
	var new_card = CardSprite.new()
	new_card.setup(card)
	add_child(new_card)

	if sorting_by == SORTING.VALUE:
		sort_by_value()
	elif sorting_by == SORTING.SUIT:
		sort_by_suit()
	else:
		_update_hand_layout()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_process_click(event.position)


func _process_click(mouse_pos: Vector2) -> void:
	var children = get_children()  #
	# Iterate backwards to catch the "top-most" card in overlaps
	for i in range(children.size() - 1, -1, -1):  #
		var sprite = children[i] as CardSprite
		if sprite and sprite.get_rect().has_point(sprite.to_local(mouse_pos)):  #
			sprite.toggle_selection()

			var data = sprite.resource
			print("Hand: Card toggled. (%s of %s)" % [data.value + 1, Card.SUIT.keys()[data.suit]])  # [cite: 1, 12]

			_update_hand_layout()
			return


# --- The Master Visual Controller ---


func _update_hand_layout() -> void:
	var children = get_children()
	var target_count = children.size()

	if target_count == 0:
		return

	var interval = total_hand_width / (target_count - 1) if target_count > 1 else 0.0
	interval = clamp(interval, min_spacing, max_spacing)

	var current_hand_width = interval * (target_count - 1)
	var start_x = -(current_hand_width / 2.0)

	for i in range(target_count):
		var sprite = children[i] as CardSprite

		# Set the Y position based on the sprite's internal selected state
		var target_y = -64 if sprite.selected else -32  #
		sprite.position = Vector2(start_x + (interval * i), target_y)


# --- Sorting Logic ---


func sort_by_value() -> void:
	sorting_by = SORTING.VALUE
	_sort_nodes(func(a, b): return a.resource.value < b.resource.value)


func sort_by_suit() -> void:
	sorting_by = SORTING.SUIT
	_sort_nodes(func(a, b): return a.resource.suit < b.resource.suit)


func _sort_nodes(comparator: Callable) -> void:
	var children = get_children()
	if children.is_empty():
		return

	# Sort the actual array of child nodes based on their resource data
	children.sort_custom(comparator)

	# Physically move the nodes in the Godot Scene Tree to match the sorted array
	for i in range(children.size()):
		move_child(children[i], i)

	# Redraw positions based on their new Scene Tree index
	_update_hand_layout()
