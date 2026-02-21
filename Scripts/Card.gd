class_name Card
extends Resource

@export var suit: SUIT
enum SUIT { HEART, DIAMOND, SPADE, CLUB }  #0-3

@export var value: int  # 0-14?
@export var atlas: AtlasTexture
