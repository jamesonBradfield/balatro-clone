class_name Card
extends Resource

@export var suit: SUIT
enum SUIT { HEART, DIAMOND, SPADE, CLUB }  #0-3

@export var value: int  # 0-14?
@export var atlas: AtlasTexture


func get_card_name() -> String:
	var string_value
	if value <= 9 and value > 0:
		string_value = str(value + 1)
	else:
		if value == 10:
			string_value = "Jack"
		if value == 11:
			string_value = "queen"
		if value == 12:
			string_value = "king"
		if value == 0:
			string_value = "ace"
	return string_value + " of " + SUIT.keys()[suit]
