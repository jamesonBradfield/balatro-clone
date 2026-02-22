class_name ResponsiveRegion
extends Node2D

@export_range(0, 100) var coverage_percentage: int = 50
@export var max_spacing: float = 100.0
@export var min_spacing: float = 10.0

var parent_size: Vector2
var region_width: float


func _ready() -> void:
	_update_size()
	get_viewport().size_changed.connect(_on_viewport_resized)


func _on_viewport_resized() -> void:
	_update_size()
	on_resize()


func _update_size() -> void:
	parent_size = get_viewport_rect().size
	region_width = parent_size.x * (coverage_percentage / 100.0)
	print(region_width)


func on_resize() -> void:
	pass
