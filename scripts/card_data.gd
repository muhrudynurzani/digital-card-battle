extends Resource
class_name CardData

enum CardAttribute {
	VACCINE,
	VIRUS,
	DATA,
	FREE
}

enum CardElement {
	FIRE,
	ICE,
	NATURE,
	DARKNESS,
	RARE
}

enum CardType {
	DIGIMON,
	OPTION
}

@export var card_name: String = "New Digimon"
@export var attribute: CardAttribute = CardAttribute.VACCINE
@export var element: CardElement = CardElement.FIRE
@export var card_type: CardType = CardType.DIGIMON

@export_range(0, 999) var hp: int = 30
@export_range(0, 999) var deadly_attack: int = 20
@export_range(0, 999) var normal_attack: int = 20
@export_range(0, 999) var special_attack: int = 20
@export_multiline var special_effect: String = ""
@export_multiline var support_effect: String = ""
