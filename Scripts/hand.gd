extends Node2D

signal on_cards_resized(count: int)

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
	on_cards_resized.emit(cards.size())


## fans out cards based on updated screen size.
func _fan_out_cards():
	# 1. Clear existing visual nodes to ensure the array is the SSOT
	for child in get_children():
		child.queue_free()

	if cards.is_empty():
		return

	# 2. Calculate the interval based on the source array
	var interval = 0.0
	if cards.size() > 1:
		interval = total_hand_width / (cards.size() - 1)

	# 3. Build visuals directly from the Resource array [cite: 7, 8]
	for i in range(cards.size()):
		var card_data = cards[i]
		var sprite = Sprite2D.new()
		sprite.texture = card_data.atlas
		add_child(sprite)
		var x_pos = cards_x_min + (interval * i)
		sprite.position = Vector2(x_pos, -32)
