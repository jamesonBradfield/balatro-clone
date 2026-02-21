extends Node
@export_dir var cards_folder: String
var all_cards: Array[Card] = []
@export var deck: Deck
@export var hand: Hand
signal card_drawn(card: Card)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# In your main scene script or a connected setup
	card_drawn.connect(hand._draw_card)
	# load_cards_from_folder()
	randomize()
	deck.deck.shuffle()
	for index in range(0, 7):
		draw_card()


func draw_card():
	card_drawn.emit(deck.deck.pop_front())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func load_cards_from_folder():
	if cards_folder.is_empty():
		push_warning("Cards folder empty or not set!")
		return
	var dir = DirAccess.open(cards_folder)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()

		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var full_path = cards_folder + "/" + file_name
				var resource = load(full_path)

				if resource is Card:
					all_cards.append(resource)
					print("Loaded card: ", file_name, " (Suit: ", resource.suit, ")")
				file_name = dir.get_next()
			else:
				push_error("Failed to access path: " + cards_folder)


func _on_button_pressed() -> void:
	pass  # Replace with function body.
