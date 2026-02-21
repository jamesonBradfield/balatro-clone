@tool
class_name CardAtlasCreator
extends EditorScript

var card_size: Vector2i = Vector2i(48, 64)
var atlas
var save_dir: String = ""
var window: Window
var array: Array[int] = [15, 13, 13, 13]


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	window = Window.new()
	EditorInterface.popup_dialog(window, Rect2(Vector2(100, 100), Vector2(500, 500)))

	# 1. Instantiate our new custom UI nodes
	var path_ui := PrettyFileDialog.new("Path:", FileDialog.FileMode.FILE_MODE_OPEN_DIR)
	var atlas_ui := PrettyFileDialog.new("Atlas:", FileDialog.FileMode.FILE_MODE_OPEN_FILE)
	var vector_ui := Vector2Input.new(card_size, "Size:")

	var texture_rect := TextureRect.new()
	# 2. Connect to their custom signals to update our main variables
	path_ui.dir_selected.connect(func(new_path: String): save_dir = new_path)
	atlas_ui.dir_selected.connect(
		func(new_path: String):
			atlas = load(new_path)
			texture_rect.texture = atlas
	)
	vector_ui.value_changed.connect(func(new_val: Vector2i): card_size = new_val)

	# 3. Setup the main window layout
	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(
		Control.LayoutPreset.PRESET_FULL_RECT, Control.LayoutPresetMode.PRESET_MODE_KEEP_SIZE, 0
	)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.custom_minimum_size = Vector2(0, 200)
	var panel := Panel.new()
	panel.set_anchors_and_offsets_preset(
		Control.LayoutPreset.PRESET_FULL_RECT, Control.LayoutPresetMode.PRESET_MODE_KEEP_SIZE, 0
	)

	var build_cards := Button.new()
	build_cards.text = "Build Cards!"
	build_cards.pressed.connect(_on_build_cards_pressed)

	# 4. Add everything to the window
	window.add_child(panel)
	window.add_child(vbox)
	vbox.add_child(texture_rect)
	vbox.add_child(atlas_ui)
	vbox.add_child(path_ui)
	vbox.add_child(vector_ui)
	vbox.add_child(build_cards)

	window.close_requested.connect(func(): window.queue_free())


func _on_build_cards_pressed() -> void:
	if save_dir == "":
		print("Error: Please select a save directory first!")
		return

	# Grab the string names from your custom class enum ["HEART", "DIAMOND", "CLUB", "SPADE"]
	var suit_names = Card.SUIT.keys()

	for x in range(0, 15):
		for y in range(0, 4):
			if array[y] - 1 >= x:
				# 1. Generate the texture region
				var new_atlas_texture := AtlasTexture.new()
				new_atlas_texture.atlas = self.atlas
				new_atlas_texture.region = Rect2(
					x * card_size.x, y * card_size.y, card_size.x, card_size.y
				)

				# 2. Instantiate your custom Card resource and populate it
				var new_card := Card.new()
				new_card.atlas = new_atlas_texture
				new_card.suit = y as Card.SUIT  # Cast the y index to your enum
				new_card.value = x

				# 3. Format the filename nicely
				var suit_string = suit_names[y].to_lower()
				var rank_string = str(x)

				# Optional: Make the face cards readable in the file system
				match x:
					1:
						rank_string = "ace"
					11:
						rank_string = "jack"
					12:
						rank_string = "queen"
					13:
						rank_string = "king"
					14:
						rank_string = "joker"

				# Append an 's' to the suit so it reads "ace_of_hearts" instead of "ace_of_heart"
				var file_name = save_dir + "/" + rank_string + "_of_" + suit_string + "s.tres"

				# 4. Save the Card resource (not just the texture!)
				ResourceSaver.save(new_card, file_name)

	print("Success! Cards generated in: ", save_dir)


# ==========================================
# CUSTOM INNER CLASSES FOR CLEAN UI
# ==========================================


class Vector2Input:
	extends GridContainer
	signal value_changed(new_value: Vector2i)
	var current_value: Vector2i

	func _init(default_value: Vector2i, label_text: String) -> void:
		self.columns = 5
		self.current_value = default_value
		self.set_anchors_and_offsets_preset(
			Control.LayoutPreset.PRESET_FULL_RECT, Control.LayoutPresetMode.PRESET_MODE_KEEP_SIZE, 0
		)

		var var_label := Label.new()
		var_label.text = label_text
		var_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var x_label := Label.new()
		x_label.text = "X:"
		x_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var x_spin := SpinBox.new()
		x_spin.value = current_value.x
		x_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var y_label := Label.new()
		y_label.text = "Y:"
		y_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var y_spin := SpinBox.new()
		y_spin.value = current_value.y
		y_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		# Emit signal whenever either box changes
		x_spin.value_changed.connect(
			func(val):
				current_value.x = val
				value_changed.emit(current_value)
		)
		y_spin.value_changed.connect(
			func(val):
				current_value.y = val
				value_changed.emit(current_value)
		)

		add_child(var_label)
		add_child(x_label)
		add_child(x_spin)
		add_child(y_label)
		add_child(y_spin)


class PrettyFileDialog:
	extends HBoxContainer
	signal dir_selected(path: String)
	var file_dialog: FileDialog

	func _init(label_text: String, mode: FileDialog.FileMode) -> void:
		self.set_anchors_and_offsets_preset(
			Control.LayoutPreset.PRESET_FULL_RECT, Control.LayoutPresetMode.PRESET_MODE_KEEP_SIZE, 0
		)

		var path_label := Label.new()
		path_label.text = label_text
		path_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var line_edit := LineEdit.new()
		line_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		line_edit.editable = false  # Prevents typos!

		var btn := Button.new()
		btn.text = "..."

		file_dialog = FileDialog.new()
		file_dialog.file_mode = mode
		btn.pressed.connect(func(): file_dialog.popup())
		file_dialog.dir_selected.connect(
			func(chosen_path: String):
				line_edit.text = chosen_path
				dir_selected.emit(chosen_path)
		)

		file_dialog.file_selected.connect(
			func(chosen_path: String):
				line_edit.text = chosen_path
				dir_selected.emit(chosen_path)
		)
		add_child(path_label)
		add_child(line_edit)
		add_child(btn)
		add_child(file_dialog)
