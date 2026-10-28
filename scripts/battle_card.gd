
extends Control
class_name BattleCardView

signal card_selected(card: CardData)

@onready var border: Panel = $Panel
@onready var art_placeholder: ColorRect = $Panel/ArtPlaceholder
@onready var select_button: Button = $SelectButton

var card_data: CardData
var detail_popup: PanelContainer
var hide_timer: Timer


func _ready() -> void:
	_setup_card_appearance()
	_setup_popup()

	select_button.pressed.connect(_on_select_pressed)
	select_button.mouse_entered.connect(_on_mouse_entered_card)
	select_button.mouse_exited.connect(_on_mouse_exited_card)


func setup(data: CardData) -> void:
	card_data = data

	if not is_node_ready():
		await ready

	_update_card_appearance()


func _setup_card_appearance() -> void:
	# Tombol transparan agar artwork dan bingkai tetap terlihat.
	select_button.text = ""
	select_button.flat = true
	select_button.focus_mode = Control.FOCUS_NONE

	for style_name in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0, 0, 0, 0)
		style.border_width_left = 0
		style.border_width_right = 0
		style.border_width_top = 0
		style.border_width_bottom = 0
		select_button.add_theme_stylebox_override(style_name, style)

	# Artwork memenuhi kartu dengan sedikit ruang untuk bingkai.
	border.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art_placeholder.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)
	art_placeholder.offset_left = 4
	art_placeholder.offset_top = 4
	art_placeholder.offset_right = -4
	art_placeholder.offset_bottom = -4

	select_button.set_anchors_and_offsets_preset(
		Control.PRESET_FULL_RECT
	)


func _update_card_appearance() -> void:
	if card_data == null:
		return

	var frame_color: Color

	match card_data.attribute:
		CardData.CardAttribute.VACCINE:
			frame_color = Color("#42B883")
		CardData.CardAttribute.VIRUS:
			frame_color = Color("#E05252")
		CardData.CardAttribute.DATA:
			frame_color = Color("#4387E8")
		CardData.CardAttribute.FREE:
			frame_color = Color("#B8B8C0")
		_:
			frame_color = Color("#777777")

	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color("#171923")
	frame_style.border_color = frame_color
	frame_style.set_border_width_all(4)
	frame_style.set_corner_radius_all(5)

	border.add_theme_stylebox_override("panel", frame_style)

	# Warna sementara sebelum artwork asli dipasang.
	art_placeholder.color = Color("#202638")


func _setup_popup() -> void:
	detail_popup = PanelContainer.new()
	detail_popup.name = "CardDetailPopup"
	detail_popup.custom_minimum_size = Vector2(240, 0)
	detail_popup.visible = false
	detail_popup.mouse_filter = Control.MOUSE_FILTER_STOP

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 6)
	detail_popup.add_child(layout)

	var title := Label.new()
	title.name = "CardName"
	title.add_theme_font_size_override("font_size", 18)
	layout.add_child(title)

	var category := Label.new()
	category.name = "CardCategory"
	layout.add_child(category)

	var stats := Label.new()
	stats.name = "CardStats"
	layout.add_child(stats)

	var special_effect := Label.new()
	special_effect.name = "SpecialEffect"
	special_effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(special_effect)

	var support_effect := Label.new()
	support_effect.name = "SupportEffect"
	support_effect.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(support_effect)

	hide_timer = Timer.new()
	hide_timer.one_shot = true
	hide_timer.wait_time = 0.2
	hide_timer.timeout.connect(_hide_popup)
	add_child(hide_timer)

	detail_popup.mouse_entered.connect(_on_mouse_entered_popup)
	detail_popup.mouse_exited.connect(_on_mouse_exited_popup)


func _on_mouse_entered_card() -> void:
	hide_timer.stop()
	_show_popup()


func _on_mouse_exited_card() -> void:
	_schedule_hide_popup()


func _show_popup() -> void:
	if card_data == null:
		return

	var scene_root := get_tree().current_scene
	if scene_root == null:
		return

	if detail_popup.get_parent() == null:
		scene_root.add_child(detail_popup)

	var layout := detail_popup.get_child(0) as VBoxContainer

	var title := layout.get_node("CardName") as Label
	var category := layout.get_node("CardCategory") as Label
	var stats := layout.get_node("CardStats") as Label
	var special_effect := layout.get_node("SpecialEffect") as Label
	var support_effect := layout.get_node("SupportEffect") as Label

	title.text = card_data.card_name

	category.text = "%s | %s | %s" % [
		CardData.CardAttribute.keys()[card_data.attribute],
		CardData.CardElement.keys()[card_data.element],
		CardData.CardType.keys()[card_data.card_type]
	]

	stats.text = "HP: %d\nDA: %d\nNA: %d\nSA: %d" % [
		card_data.hp,
		card_data.deadly_attack,
		card_data.normal_attack,
		card_data.special_attack
	]

	special_effect.visible = not card_data.special_effect.is_empty()
	special_effect.text = "Special: " + card_data.special_effect

	support_effect.visible = not card_data.support_effect.is_empty()
	support_effect.text = "Support: " + card_data.support_effect

	detail_popup.reset_size()

	var viewport_size := get_viewport_rect().size
	var card_rect := get_global_rect()
	var popup_size := detail_popup.get_combined_minimum_size()

	var popup_position := card_rect.position + Vector2(
		card_rect.size.x + 8,
		0
	)

	# Jika ruang di kanan tidak cukup, tampilkan di kiri kartu.
	if popup_position.x + popup_size.x > viewport_size.x:
		popup_position.x = card_rect.position.x - popup_size.x - 8

	# Jaga agar popup tetap berada di dalam viewport.
	popup_position.x = clampf(
		popup_position.x, 0.0,
		maxf(0.0, viewport_size.x - popup_size.x)
	)

	popup_position.y = clampf(
		card_rect.position.y,
		0.0,
		maxf(0.0, viewport_size.y - popup_size.y)
	)

	detail_popup.position = popup_position
	detail_popup.show()


func _on_mouse_entered_popup() -> void:
	hide_timer.stop()


func _on_mouse_exited_popup() -> void:
	_schedule_hide_popup()


func _schedule_hide_popup() -> void:
	hide_timer.start()


func _hide_popup() -> void:
	if is_instance_valid(detail_popup):
		detail_popup.hide()


func _on_select_pressed() -> void:
	if card_data != null:
		card_selected.emit(card_data)


func _exit_tree() -> void:
	if is_instance_valid(detail_popup):
		detail_popup.queue_free()
