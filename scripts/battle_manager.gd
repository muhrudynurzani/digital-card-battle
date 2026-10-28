
extends Control

const PHAND_ZONE_SCENE: PackedScene = preload("res://scenes/battle/playerhandzone.tscn")
const EHAND_ZONE_SCENE: PackedScene = preload("res://scenes/battle/enemyhandzone.tscn")

const INITIAL_HAND_SIZE: int = 4

var player_deck: Array[CardData] = []
var enemy_deck: Array[CardData] = []

var player_hand: Array[CardData] = []
var enemy_hand: Array[CardData] = []

var player_trash: Array[CardData] = []
var enemy_trash: Array[CardData] = []

var player_score: int = 0
var enemy_score: int = 0

var player_active: CardData
var enemy_active: CardData

var player_hand_zone: HandZone
var enemy_hand_zone: HandZone

var player_active_label: Label
var enemy_active_label: Label
var battle_log: RichTextLabel


func _ready() -> void:
	randomize()

	create_sample_decks()
	draw_initial_hands()
	build_interface()
	update_interface()


# ==================================================
# DATA KARTU SEMENTARA
# ==================================================

func create_sample_decks() -> void:
	player_deck.clear()
	enemy_deck.clear()

	player_deck.append(make_card(
		"Flame Rookie", CardData.CardAttribute.VIRUS,
		CardData.CardElement.FIRE, 40, 30, 20, 35
	))
	player_deck.append(make_card(
		"Aqua Rookie", CardData.CardAttribute.DATA,
		CardData.CardElement.ICE, 35, 25, 25, 30
	))
	player_deck.append(make_card(
		"Forest Rookie", CardData.CardAttribute.VACCINE,
		CardData.CardElement.NATURE, 45, 20, 25, 30
	))
	player_deck.append(make_card(
		"Shadow Rookie", CardData.CardAttribute.VIRUS,
		CardData.CardElement.DARKNESS, 30, 40, 25, 35
	))
	player_deck.append(make_card(
		"Light Rookie", CardData.CardAttribute.VACCINE,
		CardData.CardElement.RARE, 40, 25, 30, 35
	))
	player_deck.append(make_card(
		"Ice Rookie", CardData.CardAttribute.DATA,
		CardData.CardElement.ICE, 35, 30, 25, 40
	))

	enemy_deck.append(make_card(
		"Wind Rookie", CardData.CardAttribute.DATA,
		CardData.CardElement.NATURE, 35, 30, 25, 30
	))
	enemy_deck.append(make_card(
		"Thunder Rookie", CardData.CardAttribute.VIRUS,
		CardData.CardElement.RARE, 40, 35, 25, 30
	))
	enemy_deck.append(make_card(
		"Stone Rookie", CardData.CardAttribute.VACCINE,
		CardData.CardElement.NATURE, 45, 20, 30, 25
	))
	enemy_deck.append(make_card(
		"Dark Rookie", CardData.CardAttribute.VIRUS,
		CardData.CardElement.DARKNESS, 30, 40, 20, 35
	))
	enemy_deck.append(make_card(
		"Water Rookie", CardData.CardAttribute.DATA,
		CardData.CardElement.ICE, 35, 25, 30, 35
	))
	enemy_deck.append(make_card(
		"Rare Rookie", CardData.CardAttribute.FREE,
		CardData.CardElement.RARE, 40, 30, 25, 40
	))


func make_card(
	card_name: String,
	attribute: CardData.CardAttribute,
	element: CardData.CardElement,
	hp: int,
	da: int,
	na: int,
	sa: int
) -> CardData:
	var card := CardData.new()

	card.card_name = card_name
	card.attribute = attribute
	card.element = element
	card.card_type = CardData.CardType.DIGIMON

	card.hp = hp
	card.deadly_attack = da
	card.normal_attack = na
	card.special_attack = sa

	return card


func draw_initial_hands() -> void:
	player_hand.clear()
	enemy_hand.clear()

	for i in range(INITIAL_HAND_SIZE):
		if not player_deck.is_empty():
			player_hand.append(player_deck.pop_front())

		if not enemy_deck.is_empty():
			enemy_hand.append(enemy_deck.pop_front())


# ==================================================
# MEMBANGUN INTERFACE
# ==================================================


func build_interface() -> void:
	# Layout utama: area battle di kiri, sidebar di kanan.
	var main_layout := HBoxContainer.new()
	main_layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main_layout.add_theme_constant_override("separation", 10)
	add_child(main_layout)

	# ==========================================
	# AREA BATTLE - KIRI
	# ==========================================

	var battle_area := VBoxContainer.new()
	battle_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	battle_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	battle_area.add_theme_constant_override("separation", 6)
	main_layout.add_child(battle_area)

	# Area musuh
	battle_area.add_child(make_section_title("ENEMY"))

	enemy_hand_zone = EHAND_ZONE_SCENE.instantiate() as HandZone
	enemy_hand_zone.custom_minimum_size = Vector2(0, 200)
	enemy_hand_zone.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	battle_area.add_child(enemy_hand_zone)
	
	var enemy_active_panel := make_active_zone(false)
	battle_area.add_child(enemy_active_panel)

	battle_area.add_child(HSeparator.new())

	# Area pemain
	var player_active_panel := make_active_zone(true)
	battle_area.add_child(player_active_panel)

	player_hand_zone = PHAND_ZONE_SCENE.instantiate() as HandZone
	player_hand_zone.custom_minimum_size = Vector2(0, 200)
	player_hand_zone.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	battle_area.add_child(player_hand_zone)
	
	battle_area.add_child(make_section_title("PLAYER"))

	player_hand_zone.card_selected.connect(_on_player_card_selected)

	# ==========================================
	# BATTLE LOG - SIDEBAR KANAN
	# ==========================================

	var sidebar := PanelContainer.new()
	sidebar.custom_minimum_size = Vector2(240, 0)
	sidebar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_layout.add_child(sidebar)

	var sidebar_layout := VBoxContainer.new()
	sidebar_layout.add_theme_constant_override("separation", 8)
	sidebar.add_child(sidebar_layout)

	var log_title := Label.new()
	log_title.text = "BATTLE LOG"
	log_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	log_title.add_theme_font_size_override("font_size", 18)
	sidebar_layout.add_child(log_title)

	var separator := HSeparator.new()
	sidebar_layout.add_child(separator)

	battle_log = RichTextLabel.new()
	battle_log.fit_content = false
	battle_log.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	battle_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	battle_log.scroll_following = true
	battle_log.text = "Battle siap."
	sidebar_layout.add_child(battle_log)

func make_section_title(title_text: String) -> Label:
	var label := Label.new()
	label.text = title_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	return label


func make_active_zone(is_player: bool) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 55)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)

	var title := Label.new()
	title.text = "ACTIVE ZONE"
	title.custom_minimum_size = Vector2(130, 0)
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(title)

	var active_label := Label.new()
	active_label.text = "Belum ada Digimon aktif"
	active_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	active_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(active_label)

	if is_player:
		player_active_label = active_label
	else:
		enemy_active_label = active_label

	return panel


# ==================================================
# UPDATE TAMPILAN
# ==================================================

func update_interface() -> void:
	if not is_instance_valid(player_hand_zone):
		return

	player_hand_zone.set_zone_counts(
		player_trash.size(),
		player_deck.size()
	)
	enemy_hand_zone.set_zone_counts(
		enemy_trash.size(),
		enemy_deck.size()
	)

	player_hand_zone.display_hand(player_hand, true)
	enemy_hand_zone.display_hand(enemy_hand, false)

	player_hand_zone.set_score(player_score)
	enemy_hand_zone.set_score(enemy_score)

	if player_active == null:
		player_active_label.text = "Belum ada Digimon aktif"
	else:
		player_active_label.text = "%s | HP: %d" % [
			player_active.card_name,
			player_active.hp
		]

	if enemy_active == null:
		enemy_active_label.text = "Belum ada Digimon aktif"
	else:
		enemy_active_label.text = "%s | HP: %d" % [
			enemy_active.card_name,
			enemy_active.hp
		]


# ==================================================
# PEMILIHAN KARTU SEMENTARA
# ==================================================

func _on_player_card_selected(card: CardData) -> void:
	battle_log.append_text(
		"\nKartu dipilih: %s" % card.card_name
	)
