# 🌟 The "Pie in the Sky" Vision

A modular, data-driven card engine where the visual identity is decoupled from the game logic. By using a Card Overlay System, we can generate a standard 52-card deck and then "programmatically" create Jokers, Elites, or Corrupted cards by layering icons and effects over base resources—allowing for infinite iteration without needing new art for every variation.
🛠️ The Todo List
## 1. Deck Management (Resource)

	Dynamic Deck: Create a Deck.tres that stores Array[Card]. 

	Card Operations: Implement add_card_to_deck(), destroy_card(), and shuffle().

	The "Weighted Draw" System:

		Implement a priority or weight variable on the Card resource. 

		Logic to increase draw probability for "marked" cards without removing others from the pool.

	Card Pool: A master list of all available cards for the player to "draft" from.

## 2. Card Instantiation & Visuals

	UI Representation: Create a CardUI scene (Sprite2D/Control) that accepts a Card resource. 

	Hand Integration: Update hand.gd to instantiate these scenes whenever _draw_card is called. 

	Fan-Out Logic: Finalize _fan_out_cards() to position and rotate instantiated nodes based on screen_coverage_percentage. 

## 3. Game Loop & Turn Lifecycle

	Turn Manager: A central node to handle the "Draw -> Play -> Score -> Discard" loop.

	Scoring Engine: A ScoringNode that calculates value based on Card.suit and Card.value. 

	Level Manager: A difficulty controller that uses Curve resources to scale enemy health or score requirements over time.

## 4. The Overlay Tool (Joker Idea)

	Abstraction: Refactor CardAtlasCreator.gd into a base AtlasSlicer class. 

	Overlay Customizer: A new tool script to:

		Take a "Base Card" resource.

		Apply a Texture2D logo/overlay to the center.

		Save as a "SpecialCard" resource (extending the base Card). 

## 📈 Architecture Notes

	ResponsiveRegion: Generic Node2D base class for percentage-based layout. Any region (hand, play area, etc.) can extend it and override `on_resize()`.

	CardSprite: Owns its visual state (modulate, selection offset) and input handling. Emits `selection_toggled` signal for parent coordination.

	Hand: Extends ResponsiveRegion. Orchestrates card creation, sorting, and X positioning. Delegates visual state to CardSprite.

	Resource Purity: Keep the Card resource as data-only. All "logic" (movement, hovering, glowing) should live in the CardSprite node.
