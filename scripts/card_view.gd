extends Control
class_name CardView

signal card_selected(card: CardData)

@onready var name_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/NameLabel
@onready var attribute_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/AttributeLabel
@onready var element_label: Label = $PanelContainer/MarginContainer/VBoxContainer/ElementLabel
@onready var art_placeholder: ColorRect = $PanelContainer/MarginContainer/VBoxContainer/ArtPlaceholder
@onready var stats_label: Label = $PanelContainer/MarginContainer/VBoxContainer/StatsLabel
@onready var select_button: Button = $SelectButton

var card_data: CardData


func _ready() -> void:
	select_button.pressed.connect(_on_select_pressed)


func setup(data: CardData) -> void:
	card_data = data

	if not is_node_ready():
		await ready

	name_label.text = data.card_name
	attribute_label.text = CardData.CardAttribute.keys()[data.attribute]
	element_label.text = CardData.CardElement.keys()[data.element]
	stats_label.text = (
    "HP: %d\nDA: %d\nNA: %d\nSA: %d"
	% [
		data.hp,
		data.deadly_attack,
		data.normal_attack,
		data.special_attack
	]
)


func _on_select_pressed() -> void:
	if card_data != null:
		card_selected.emit(card_data)
