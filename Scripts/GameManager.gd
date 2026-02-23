class_name GameManager
extends Node

@export var deck: DeckManager
@export var hand: Hand
@export var scoring: ScoreManager


func _ready() -> void:
	hand.hand_played.connect(scoring._hand_played)
	# Connect the deck's signal directly to the hand's draw function
	deck.card_drawn.connect(hand._draw_card)

	# Start the game!
	deck.deal_starting_hand(7)


func _process(_delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	# If you have a "Draw Card" UI button, it just tells the deck to do its thing
	deck.draw_card()
