class_name Hand
extends ResponsiveRegion

var sorting_by: SORTING
enum SORTING { VALUE, SUIT }
var selected: Array[Card]
signal hand_played(sprite: Array[CardSprite])


func _ready() -> void:
	super._ready()
	global_position = Vector2(parent_size.x / 2.0, parent_size.y)


func on_resize() -> void:
	global_position = Vector2(parent_size.x / 2.0, parent_size.y)
	_update_hand_layout()


func _draw_card(card: Card) -> void:
	var new_card = CardSprite.new()
	new_card.resource = card
	new_card.selection_toggled.connect(_on_card_toggled)
	add_child(new_card)

	if sorting_by == SORTING.VALUE:
		sort_by_value()
	elif sorting_by == SORTING.SUIT:
		sort_by_suit()
	_update_hand_layout()


func _play_hand() -> void:
	hand_played.emit(selected)
	selected.clear()


func _on_card_toggled(card: CardSprite) -> void:
	selected.append(card.resource)
	_update_hand_layout()


# --- The Master Visual Controller ---
func _update_hand_layout() -> void:
	if get_children().size() == 0:
		return
	var interval = region_width / (get_children().size() - 1) if get_children().size() > 1 else 0.0
	interval = clamp(interval, min_spacing, max_spacing)

	var current_hand_width = interval * (get_children().size() - 1)
	var start_x = -(current_hand_width / 2.0)
	for i in range(get_children().size()):
		var sprite = get_children()[i] as CardSprite
		sprite.position.x = start_x + (interval * i)


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
