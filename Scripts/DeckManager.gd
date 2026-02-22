class_name DeckManager
extends Node

signal card_drawn(card: Card)
signal deck_empty

# You can populate this in the inspector with your starting cards
@export var starting_deck: Array[Card] = []
var current_deck: Array[Card] = []


func _ready() -> void:
	# Duplicate the array so we don't accidentally delete cards from the original resource!
	current_deck = starting_deck.duplicate()
	randomize()
	shuffle_deck()


func shuffle_deck() -> void:
	current_deck.shuffle()
	print("Deck shuffled.")


func draw_card() -> void:
	if current_deck.is_empty():
		deck_empty.emit()
		print("Deck is empty!")
		return

	var drawn_card = current_deck.pop_front()
	card_drawn.emit(drawn_card)


func deal_starting_hand(amount: int) -> void:
	for i in range(amount):
		draw_card()
