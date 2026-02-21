class_name Hand
extends Node2D

## cards in hand.
@export var cards: Array[Card]
## defines how much of the screen our hand covers.
@export_range(0, 100) var screen_coverage_percentage: int
## screen size in pixels
var screen_size: Vector2
var cards_center: Vector2
var cards_x_max: float
var cards_x_min: float
var total_hand_width
##WARNING: use card.atlas.size/2?
@export var max_spacing: float
@export var min_spacing: float
var selected_card_indices: Array[int] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_screen_size()
	get_viewport().size_changed.connect(_update_screen_size)
	_fan_out_cards()


## recalculate card bounds based on screen_size.
func _update_screen_size():
	screen_size = get_viewport_rect().size

	# 1. Place this node at the bottom-center of the screen
	cards_center = Vector2(screen_size.x / 2.0, screen_size.y)
	global_position = cards_center

	# 2. Calculate the total width the hand should occupy
	# Using 100.0 ensures we don't do integer division
	total_hand_width = screen_size.x * (screen_coverage_percentage / 100.0)

	# 3. Calculate bounds relative to the center (0,0 of this node)
	cards_x_min = -(total_hand_width / 2.0)
	cards_x_max = (total_hand_width / 2.0)

	print("Hand width: %s | Min: %s | Max: %s" % [total_hand_width, cards_x_min, cards_x_max])


## add card to cards in hand.
func _draw_card(card: Card) -> void:
	cards.append(card)
	_fan_out_cards()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_check_for_card_selection(event.position)


func _check_for_card_selection(mouse_pos: Vector2) -> void:
	# We iterate backwards so we check the "top" cards first (if they overlap)
	var children = get_children()
	for i in range(children.size() - 1, -1, -1):
		var sprite = children[i] as Sprite2D
		if sprite:
			# Convert global mouse position to local position of the sprite
			var local_mouse_pos = sprite.to_local(mouse_pos)

			# Check if mouse is within the atlas region bounds
			var rect = sprite.get_rect()
			if rect.has_point(local_mouse_pos):
				_select_card(i)
				return  # Stop after finding the topmost card


func _select_card(index: int) -> void:
	# Toggle logic: if already selected, remove it. Otherwise, add it.
	if selected_card_indices.has(index):
		selected_card_indices.erase(index)
		print("Deselected card at index: ", index)
	else:
		selected_card_indices.append(index)
		var card_data = cards[index]
		print("Selected: %s of %s" % [card_data.value, Card.SUIT.keys()[card_data.suit]])
	# Visual feedback: Refresh the hand to show new offsets
	_fan_out_cards()


## Updated fan_out for multi-selection
func _fan_out_cards():
	for child in get_children():
		child.queue_free()

	if cards.is_empty():
		return

	var interval = 0.0
	if cards.size() > 1:
		interval = total_hand_width / (cards.size() - 1)
		interval = clamp(interval, min_spacing, max_spacing)

	var current_hand_width = interval * (cards.size() - 1)
	var start_x = -(current_hand_width / 2.0)

	for i in range(cards.size()):
		var card_data = cards[i]
		var sprite = Sprite2D.new()
		sprite.texture = card_data.atlas
		add_child(sprite)

		var x_pos = start_x + (interval * i)
		var y_offset = -32

		# Check if this specific index is in our selection array
		if selected_card_indices.has(i):
			y_offset = -64  # Visual "Lift"
			sprite.modulate = Color(1.2, 1.2, 1.2)  # Subtle highlight

		sprite.position = Vector2(x_pos, y_offset)
