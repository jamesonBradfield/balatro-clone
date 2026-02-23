class_name ScoreManager
extends Node

var cards_played: Array[Card]


func _hand_played(selected: Array[Card]):
	for index in range(0, selected.size()):
		print("Played: " + selected[index].get_card_name())
