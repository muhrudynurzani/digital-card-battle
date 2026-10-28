extends Control
class_name HandZone

signal card_selected(card: CardData)

const CARD_SCENE: PackedScene = preload("res://scenes/battle/battle_card.tscn")
const MAX_HAND_SIZE: int = 4

@onready var total_trash_label: Label = $HBoxContainer/LContainer/VBoxContainer/TrashZone/TotalTrashLabel
@onready var total_deck_label: Label = $HBoxContainer/LContainer/VBoxContainer/DeckZone/TotalCardInDeckLabel

@onready var card_slots: Array[PanelContainer] = [
	$HBoxContainer/Card1Container,
	$HBoxContainer/Card2Container,
	$HBoxContainer/Card3Container,
	$HBoxContainer/Card4Container
]

@onready var point_placeholders: Array[ColorRect] = [
	$HBoxContainer/RContainer/VBoxContainer/Point1Placeholder,
	$HBoxContainer/RContainer/VBoxContainer/Point2Placeholder,
	$HBoxContainer/RContainer/VBoxContainer/Point3Placeholder
]


func set_zone_counts(trash_count: int, deck_count: int) -> void:
	total_trash_label.text = "NT: %d" % trash_count
	total_deck_label.text = "ND: %d" % deck_count


func display_hand(cards: Array[CardData], selectable: bool = true) -> void:
	for i in range(card_slots.size()):
		var slot: PanelContainer = card_slots[i]

		for child in slot.get_children():
			slot.remove_child(child)
			child.queue_free()

		if i >= cards.size() or i >= MAX_HAND_SIZE:
			continue

		var card_view := CARD_SCENE.instantiate() as BattleCardView
		slot.add_child(card_view)

		card_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		card_view.setup(cards[i])

		if selectable:
			card_view.card_selected.connect(_on_card_selected)


func set_score(score: int) -> void:
	var safe_score: int = clampi(score, 0, point_placeholders.size())

	for i in range(point_placeholders.size()):
		if i < safe_score:
			point_placeholders[i].color = Color(0.2, 0.9, 0.3)
		else:
			point_placeholders[i].color = Color(0.3, 0.3, 0.3)


func _on_card_selected(card: CardData) -> void:
	card_selected.emit(card)
