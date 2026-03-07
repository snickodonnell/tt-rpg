extends Control

signal step_changed(new_step)

const DEFAULT_STEP_NAMES := [
	"Race",
	"Class",
	"Background",
	"Abilities",
	"Feats",
	"Equipment",
	"Summary",
]
const RACE_DATA_PATH := "res://data/races"
const CLASS_DATA_PATH := "res://data/classes"
const BACKGROUND_DATA_PATH := "res://data/backgrounds"
const FEAT_DATA_PATH := "res://data/feats"
const SKILL_DATA_PATH := "res://data/skills"
const UI_VARIANT_HUMAN_MODIFIER_SOURCE_PREFIX := "ui_variant_human_bonus_"
const UI_FEAT_MODIFIER_SOURCE_PREFIX := "ui_feat_modifier_"
const ABILITY_ORDER := ["str", "dex", "con", "int", "wis", "cha"]
const ABILITY_LABELS := {
	"str": "STR",
	"dex": "DEX",
	"con": "CON",
	"int": "INT",
	"wis": "WIS",
	"cha": "CHA",
}

@onready var current_step_content_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/CurrentStepContentLabel
@onready var race_step_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/RaceStepContainer
@onready var class_background_step_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/ClassBackgroundStepContainer
@onready var abilities_step_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/AbilitiesStepContainer
@onready var feats_step_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer
@onready var class_selection_scroll: ScrollContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/ClassBackgroundStepContainer/ClassSelectionScroll
@onready var background_section: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/ClassBackgroundStepContainer/BackgroundSection
@onready var race_list_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/RaceStepContainer/RaceSelectionScroll/RaceList
@onready var class_list_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/ClassBackgroundStepContainer/ClassSelectionScroll/ClassList
@onready var background_list_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/ClassBackgroundStepContainer/BackgroundSection/BackgroundSelectionScroll/BackgroundList
@onready var ability_rows_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/AbilitiesStepContainer/AbilitiesScroll/AbilityRows
@onready var points_spent_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/AbilitiesStepContainer/PointBuySummaryPanel/PointBuySummaryMargin/PointBuySummaryContent/PointsSpentLabel
@onready var points_remaining_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/AbilitiesStepContainer/PointBuySummaryPanel/PointBuySummaryMargin/PointBuySummaryContent/PointsRemainingLabel
@onready var point_buy_status_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/AbilitiesStepContainer/PointBuySummaryPanel/PointBuySummaryMargin/PointBuySummaryContent/PointBuyStatusLabel
@onready var variant_human_panel: PanelContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/VariantHumanPanel
@onready var variant_human_bonus_one: OptionButton = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/VariantHumanPanel/VariantHumanMargin/VariantHumanContent/VariantHumanSelectors/VariantHumanBonusOne
@onready var variant_human_bonus_two: OptionButton = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/VariantHumanPanel/VariantHumanMargin/VariantHumanContent/VariantHumanSelectors/VariantHumanBonusTwo
@onready var variant_human_status_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/VariantHumanPanel/VariantHumanMargin/VariantHumanContent/VariantHumanStatusLabel
@onready var feat_status_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/FeatStatusLabel
@onready var feat_list_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/FeatsSelectionScroll/FeatList
@onready var step_buttons_container: VBoxContainer = $RootMargin/ThreePanelLayout/LeftSidebar/SidebarMargin/SidebarContent/StepButtons
@onready var next_button: Button = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/NextButton
@onready var character_name_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/PreviewLabels/CharacterNamePreview
@onready var race_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/PreviewLabels/RacePreview
@onready var class_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/PreviewLabels/ClassPreview
@onready var background_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/PreviewLabels/BackgroundPreview
@onready var hp_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/PreviewLabels/HPPreview
@onready var str_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/PreviewLabels/STRPreview
@onready var dex_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/PreviewLabels/DEXPreview
@onready var con_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/PreviewLabels/CONPreview
@onready var int_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/PreviewLabels/INTPreview
@onready var wis_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/PreviewLabels/WISPreview
@onready var cha_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/PreviewLabels/CHAPreview

var step_names := DEFAULT_STEP_NAMES.duplicate()
var current_step := 0
var available_races := []
var available_classes := []
var available_backgrounds := []
var available_feats := []
var race_buttons := []
var class_buttons := []
var background_buttons := []
var feat_buttons := []
var selected_race: RaceResource = null
var selected_class: ClassResource = null
var selected_background: BackgroundResource = null
var selected_feat: FeatResource = null
var selected_feat_valid := false
var selected_feat_validation_message := ""
var variant_human_bonus_choices := ["", ""]
var skill_name_cache := {}
var ability_controls := {}


func _ready() -> void:
	_bind_step_buttons()
	_bind_main_area_actions()
	_ensure_current_character()
	_load_available_races()
	_load_available_classes()
	_load_available_backgrounds()
	_load_available_feats()
	_sync_selected_state_from_manager()
	_build_ability_score_controls()
	_setup_variant_human_ability_selectors()
	_update_step_buttons()
	_update_main_content()
	_update_selection_buttons()
	_refresh_ability_scores_ui()
	_refresh_feat_ui()
	_update_next_button_state()
	_refresh_preview()
	_announce_step_change()


func go_to_next_step() -> void:
	go_to_step(current_step + 1)


func go_to_previous_step() -> void:
	go_to_step(current_step - 1)


func go_to_step(index: int) -> void:
	if index < 0 or index >= step_names.size():
		return

	current_step = index
	_update_step_buttons()
	_update_main_content()
	_refresh_ability_scores_ui()
	_refresh_feat_ui()
	_update_next_button_state()
	_announce_step_change()
	step_changed.emit(step_names[current_step])


func _bind_step_buttons() -> void:
	for index in range(step_buttons_container.get_child_count()):
		var button := step_buttons_container.get_child(index) as Button
		if button == null:
			continue
		button.pressed.connect(_on_step_button_pressed.bind(index))


func _bind_main_area_actions() -> void:
	next_button.pressed.connect(go_to_next_step)
	variant_human_bonus_one.item_selected.connect(_on_variant_human_bonus_selected.bind(0))
	variant_human_bonus_two.item_selected.connect(_on_variant_human_bonus_selected.bind(1))


func _load_available_races() -> void:
	available_races.clear()
	race_buttons.clear()

	for child in race_list_container.get_children():
		child.queue_free()

	var race_files := DirAccess.get_files_at(RACE_DATA_PATH)
	race_files.sort()

	for file_name in race_files:
		if not file_name.begins_with("race_") or not file_name.ends_with(".tres"):
			continue

		var race := load("%s/%s" % [RACE_DATA_PATH, file_name]) as RaceResource
		if race == null:
			continue

		available_races.append(race)
		var race_button := _build_race_button(race, available_races.size() - 1)
		race_buttons.append(race_button)
		race_list_container.add_child(race_button)


func _load_available_classes() -> void:
	available_classes.clear()
	class_buttons.clear()

	for child in class_list_container.get_children():
		child.queue_free()

	var class_files := DirAccess.get_files_at(CLASS_DATA_PATH)
	class_files.sort()

	for file_name in class_files:
		if not file_name.begins_with("class_") or not file_name.ends_with(".tres"):
			continue

		var class_resource := load("%s/%s" % [CLASS_DATA_PATH, file_name]) as ClassResource
		if class_resource == null:
			continue

		available_classes.append(class_resource)
		var class_button := _build_class_button(class_resource, available_classes.size() - 1)
		class_buttons.append(class_button)
		class_list_container.add_child(class_button)


func _load_available_backgrounds() -> void:
	available_backgrounds.clear()
	background_buttons.clear()

	for child in background_list_container.get_children():
		child.queue_free()

	var background_files := DirAccess.get_files_at(BACKGROUND_DATA_PATH)
	background_files.sort()

	for file_name in background_files:
		if not file_name.begins_with("background_") or not file_name.ends_with(".tres"):
			continue

		var background := load("%s/%s" % [BACKGROUND_DATA_PATH, file_name]) as BackgroundResource
		if background == null:
			continue

		available_backgrounds.append(background)
		var background_button := _build_background_button(background, available_backgrounds.size() - 1)
		background_buttons.append(background_button)
		background_list_container.add_child(background_button)


func _load_available_feats() -> void:
	available_feats.clear()
	feat_buttons.clear()

	for child in feat_list_container.get_children():
		child.queue_free()

	var feat_files := DirAccess.get_files_at(FEAT_DATA_PATH)
	feat_files.sort()

	for file_name in feat_files:
		if not file_name.begins_with("feat_") or not file_name.ends_with(".tres"):
			continue

		var feat := load("%s/%s" % [FEAT_DATA_PATH, file_name]) as FeatResource
		if feat == null:
			continue

		available_feats.append(feat)
		var feat_button := _build_feat_button(feat, available_feats.size() - 1)
		feat_buttons.append(feat_button)
		feat_list_container.add_child(feat_button)


func _build_race_button(race: RaceResource, index: int) -> Button:
	var button := _create_card_button(120)
	button.pressed.connect(_on_race_selected.bind(index))

	var content_row := _create_card_row(button)

	var preview_rect := ColorRect.new()
	preview_rect.custom_minimum_size = Vector2(52, 52)
	preview_rect.color = _get_resource_color(race.resource_id)
	content_row.add_child(preview_rect)

	var info_column := _create_info_column(content_row)

	var title_label := Label.new()
	title_label.text = race.display_name
	title_label.add_theme_font_size_override("font_size", 18)
	info_column.add_child(title_label)

	var description_label := Label.new()
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.text = race.description
	info_column.add_child(description_label)

	var bonuses_label := Label.new()
	bonuses_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bonuses_label.text = _format_race_summary(race)
	info_column.add_child(bonuses_label)

	return button


func _build_class_button(class_resource: ClassResource, index: int) -> Button:
	var button := _create_card_button(148)
	button.pressed.connect(_on_class_selected.bind(index))

	var content_row := _create_card_row(button)

	var preview_rect := ColorRect.new()
	preview_rect.custom_minimum_size = Vector2(52, 52)
	preview_rect.color = _get_resource_color(class_resource.resource_id)
	content_row.add_child(preview_rect)

	var info_column := _create_info_column(content_row)

	var title_label := Label.new()
	title_label.text = class_resource.display_name
	title_label.add_theme_font_size_override("font_size", 18)
	info_column.add_child(title_label)

	var hit_die_label := Label.new()
	hit_die_label.text = "Hit Die: %s" % class_resource.hit_die
	info_column.add_child(hit_die_label)

	var description_label := Label.new()
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.text = class_resource.description
	info_column.add_child(description_label)

	var features_label := Label.new()
	features_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	features_label.text = _format_class_card_summary(class_resource)
	info_column.add_child(features_label)

	return button


func _build_background_button(background: BackgroundResource, index: int) -> Button:
	var button := _create_card_button(110)
	button.pressed.connect(_on_background_selected.bind(index))

	var content_row := _create_card_row(button)

	var preview_rect := ColorRect.new()
	preview_rect.custom_minimum_size = Vector2(44, 44)
	preview_rect.color = _get_resource_color(background.resource_id)
	content_row.add_child(preview_rect)

	var info_column := _create_info_column(content_row)

	var title_label := Label.new()
	title_label.text = background.display_name
	title_label.add_theme_font_size_override("font_size", 17)
	info_column.add_child(title_label)

	var description_label := Label.new()
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.text = background.description
	info_column.add_child(description_label)

	return button


func _build_feat_button(feat: FeatResource, index: int) -> Button:
	var button := _create_card_button(146)
	button.pressed.connect(_on_feat_selected.bind(index))

	var content_row := _create_card_row(button)

	var preview_rect := ColorRect.new()
	preview_rect.custom_minimum_size = Vector2(48, 48)
	preview_rect.color = _get_resource_color(feat.resource_id)
	content_row.add_child(preview_rect)

	var info_column := _create_info_column(content_row)

	var title_label := Label.new()
	title_label.text = feat.display_name
	title_label.add_theme_font_size_override("font_size", 18)
	info_column.add_child(title_label)

	var prerequisite_label := Label.new()
	prerequisite_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prerequisite_label.text = "Prerequisites: %s" % _format_feat_prerequisites(feat)
	info_column.add_child(prerequisite_label)

	var description_label := Label.new()
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.text = feat.description
	info_column.add_child(description_label)

	var ability_label := Label.new()
	ability_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ability_label.text = "Ability Score Increases: %s" % _format_feat_ability_score_increases(feat)
	info_column.add_child(ability_label)

	return button


func _create_card_button(min_height: int) -> Button:
	var button := Button.new()
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(0, min_height)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.text = ""
	button.clip_contents = true
	return button


func _create_card_row(button: Button) -> HBoxContainer:
	var content_margin := MarginContainer.new()
	content_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content_margin.add_theme_constant_override("margin_left", 12)
	content_margin.add_theme_constant_override("margin_top", 12)
	content_margin.add_theme_constant_override("margin_right", 12)
	content_margin.add_theme_constant_override("margin_bottom", 12)
	button.add_child(content_margin)

	var content_row := HBoxContainer.new()
	content_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_row.add_theme_constant_override("separation", 12)
	content_margin.add_child(content_row)
	return content_row


func _create_info_column(parent: Node) -> VBoxContainer:
	var info_column := VBoxContainer.new()
	info_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_column.add_theme_constant_override("separation", 6)
	parent.add_child(info_column)
	return info_column


func _build_ability_score_controls() -> void:
	ability_controls.clear()

	for child in ability_rows_container.get_children():
		child.queue_free()

	var character := CharacterCreationManager.current_character
	_ensure_base_ability_scores(character)

	for ability_key in ABILITY_ORDER:
		var row_panel := PanelContainer.new()
		row_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		ability_rows_container.add_child(row_panel)

		var row_margin := MarginContainer.new()
		row_margin.add_theme_constant_override("margin_left", 12)
		row_margin.add_theme_constant_override("margin_top", 12)
		row_margin.add_theme_constant_override("margin_right", 12)
		row_margin.add_theme_constant_override("margin_bottom", 12)
		row_panel.add_child(row_margin)

		var row := HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override("separation", 12)
		row_margin.add_child(row)

		var title_label := Label.new()
		title_label.custom_minimum_size = Vector2(42, 0)
		title_label.text = ABILITY_LABELS[ability_key]
		row.add_child(title_label)

		var slider := HSlider.new()
		slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slider.min_value = 8
		slider.max_value = 15
		slider.step = 1
		slider.tick_count = 8
		slider.value = int(character.base_ability_scores.get(ability_key, 8))
		slider.value_changed.connect(_on_ability_score_changed.bind(ability_key))
		row.add_child(slider)

		var base_label := Label.new()
		base_label.custom_minimum_size = Vector2(70, 0)
		row.add_child(base_label)

		var racial_label := Label.new()
		racial_label.custom_minimum_size = Vector2(88, 0)
		row.add_child(racial_label)

		var final_label := Label.new()
		final_label.custom_minimum_size = Vector2(70, 0)
		row.add_child(final_label)

		ability_controls[ability_key] = {
			"slider": slider,
			"base_label": base_label,
			"racial_label": racial_label,
			"final_label": final_label,
		}


func _setup_variant_human_ability_selectors() -> void:
	_populate_variant_human_selector(variant_human_bonus_one, "Choose first +1 ability")
	_populate_variant_human_selector(variant_human_bonus_two, "Choose second +1 ability")
	_sync_variant_human_selector_values()


func _populate_variant_human_selector(selector: OptionButton, placeholder: String) -> void:
	selector.clear()
	selector.add_item(placeholder)
	selector.set_item_metadata(0, "")

	for ability_key in ABILITY_ORDER:
		var item_index := selector.item_count
		selector.add_item(ABILITY_LABELS[ability_key])
		selector.set_item_metadata(item_index, ability_key)


func _update_step_buttons() -> void:
	for index in range(step_buttons_container.get_child_count()):
		var button := step_buttons_container.get_child(index) as Button
		if button == null:
			continue
		button.button_pressed = index == current_step


func _update_main_content() -> void:
	race_step_container.visible = current_step == 0
	class_background_step_container.visible = current_step == 1 or current_step == 2
	abilities_step_container.visible = current_step == 3
	feats_step_container.visible = current_step == 4
	class_selection_scroll.visible = current_step == 1
	background_section.visible = current_step == 2
	next_button.visible = current_step == 0 or current_step == 1 or current_step == 2 or current_step == 3 or current_step == 4

	match current_step:
		0:
			current_step_content_label.text = "Race Selection"
		1:
			current_step_content_label.text = "Class Selection"
		2:
			current_step_content_label.text = "Background Selection"
		3:
			current_step_content_label.text = "Ability Scores"
		4:
			current_step_content_label.text = "Feats Selection"
		_:
			current_step_content_label.text = "Current Step Content"


func _update_selection_buttons() -> void:
	_update_race_buttons()
	_update_class_buttons()
	_update_background_buttons()
	_update_feat_buttons()


func _update_race_buttons() -> void:
	for index in range(race_buttons.size()):
		var button := race_buttons[index] as Button
		if button == null:
			continue
		var race := available_races[index] as RaceResource
		button.button_pressed = _is_selected_race(race)


func _update_class_buttons() -> void:
	for index in range(class_buttons.size()):
		var button := class_buttons[index] as Button
		if button == null:
			continue
		var class_resource := available_classes[index] as ClassResource
		button.button_pressed = _is_selected_class(class_resource)


func _update_background_buttons() -> void:
	for index in range(background_buttons.size()):
		var button := background_buttons[index] as Button
		if button == null:
			continue
		var background := available_backgrounds[index] as BackgroundResource
		button.button_pressed = _is_selected_background(background)


func _update_feat_buttons() -> void:
	for index in range(feat_buttons.size()):
		var button := feat_buttons[index] as Button
		if button == null:
			continue
		var feat := available_feats[index] as FeatResource
		button.button_pressed = _is_selected_feat(feat)


func _update_next_button_state() -> void:
	match current_step:
		0:
			next_button.disabled = selected_race == null
		1:
			next_button.disabled = selected_class == null
		2:
			next_button.disabled = not _can_advance_from_background_step()
		3:
			next_button.disabled = _calculate_point_buy_total() != 27
		4:
			next_button.disabled = not _can_advance_from_feats_step()
		_:
			next_button.disabled = true


func _refresh_ability_scores_ui() -> void:
	if ability_controls.is_empty():
		return

	var character := CharacterCreationManager.current_character
	_ensure_base_ability_scores(character)

	for ability_key in ABILITY_ORDER:
		var controls := ability_controls[ability_key] as Dictionary
		var slider := controls["slider"] as HSlider
		var base_label := controls["base_label"] as Label
		var racial_label := controls["racial_label"] as Label
		var final_label := controls["final_label"] as Label

		var base_score := int(character.base_ability_scores.get(ability_key, 8))
		var racial_bonus := _get_racial_ability_bonus(selected_race, ability_key)
		var final_score := _get_final_ability_score(character, selected_race, ability_key)

		slider.set_value_no_signal(base_score)
		base_label.text = "Base: %d" % base_score
		racial_label.text = "Racial: %s" % _format_signed_value(racial_bonus)
		final_label.text = "Final: %d" % final_score

	_update_point_buy_summary()


func _update_point_buy_summary() -> void:
	var total_spent := _calculate_point_buy_total()
	var remaining := 27 - total_spent

	points_spent_label.text = "Points Spent: %d / 27" % total_spent
	points_remaining_label.text = "Points Remaining: %d" % remaining

	if remaining == 0:
		point_buy_status_label.text = "Point buy complete."
		_set_label_color(points_remaining_label, Color(0.2, 0.7, 0.3))
		_set_label_color(point_buy_status_label, Color(0.2, 0.7, 0.3))
	elif remaining > 0:
		point_buy_status_label.text = "%d points remaining." % remaining
		_set_label_color(points_remaining_label, Color(0.85, 0.65, 0.2))
		_set_label_color(point_buy_status_label, Color(0.85, 0.65, 0.2))
	else:
		point_buy_status_label.text = "Over budget by %d points." % abs(remaining)
		_set_label_color(points_remaining_label, Color(0.85, 0.25, 0.25))
		_set_label_color(point_buy_status_label, Color(0.85, 0.25, 0.25))


func _refresh_feat_ui() -> void:
	variant_human_panel.visible = _is_variant_human_selected()
	_sync_variant_human_selector_values()
	_update_variant_human_status()
	_update_feat_status()


func _refresh_preview() -> void:
	var character := CharacterCreationManager.current_character
	var race := selected_race

	character_name_preview.text = "[b]Character Name:[/b] %s" % _get_character_name(character)
	race_preview.text = "[b]Race:[/b] %s" % _format_race_preview(race)
	class_preview.text = "[b]Class:[/b] %s" % _format_class_preview(character)
	background_preview.text = "[b]Background:[/b] %s" % _format_background_preview(character)
	hp_preview.text = "[b]HP:[/b] %s" % _format_hp_preview(character, race)

	var ability_previews := {
		"str": str_preview,
		"dex": dex_preview,
		"con": con_preview,
		"int": int_preview,
		"wis": wis_preview,
		"cha": cha_preview,
	}

	for ability_key in ABILITY_ORDER:
		var preview_label := ability_previews[ability_key] as RichTextLabel
		preview_label.text = "[b]%s:[/b] %s" % [ABILITY_LABELS[ability_key], _format_ability_preview(character, race, ability_key)]


func _announce_step_change() -> void:
	print("Switched to step: %s" % step_names[current_step])


func _on_step_button_pressed(index: int) -> void:
	go_to_step(index)


func _on_race_selected(index: int) -> void:
	if index < 0 or index >= available_races.size():
		return

	selected_race = available_races[index] as RaceResource
	if not _is_variant_human_selected():
		variant_human_bonus_choices = ["", ""]

	_ensure_current_character()
	CharacterCreationManager.current_character.race = selected_race
	_apply_variant_human_bonus_modifiers()
	_revalidate_selected_feat()
	_recalculate_character_hp()
	_update_selection_buttons()
	_refresh_feat_ui()
	_refresh_ability_scores_ui()
	_update_next_button_state()
	_refresh_preview()


func _on_class_selected(index: int) -> void:
	if index < 0 or index >= available_classes.size():
		return

	selected_class = available_classes[index] as ClassResource
	_ensure_current_character()
	CharacterCreationManager.current_character.class_resource = selected_class
	_revalidate_selected_feat()
	_recalculate_character_hp()
	_update_selection_buttons()
	_refresh_feat_ui()
	_refresh_ability_scores_ui()
	_update_next_button_state()
	_refresh_preview()


func _on_background_selected(index: int) -> void:
	if index < 0 or index >= available_backgrounds.size():
		return

	selected_background = available_backgrounds[index] as BackgroundResource
	_ensure_current_character()
	CharacterCreationManager.current_character.background = selected_background
	_update_selection_buttons()
	_refresh_feat_ui()
	_refresh_ability_scores_ui()
	_update_next_button_state()
	_refresh_preview()


func _on_feat_selected(index: int) -> void:
	if index < 0 or index >= available_feats.size():
		return

	var feat := available_feats[index] as FeatResource
	if selected_feat != null and selected_feat.resource_id == feat.resource_id:
		selected_feat = null
	else:
		selected_feat = feat

	_revalidate_selected_feat()
	_recalculate_character_hp()
	_update_selection_buttons()
	_refresh_feat_ui()
	_refresh_ability_scores_ui()
	_update_next_button_state()
	_refresh_preview()


func _on_ability_score_changed(value: float, ability_key: String) -> void:
	var character := CharacterCreationManager.current_character
	_ensure_base_ability_scores(character)
	character.base_ability_scores[ability_key] = int(value)
	_revalidate_selected_feat()
	_recalculate_character_hp()
	_refresh_ability_scores_ui()
	_refresh_feat_ui()
	_update_next_button_state()
	_refresh_preview()


func _on_variant_human_bonus_selected(index: int, slot: int) -> void:
	if slot < 0 or slot >= variant_human_bonus_choices.size():
		return

	var selector := variant_human_bonus_one if slot == 0 else variant_human_bonus_two
	var metadata = selector.get_item_metadata(index)
	var ability_key := ""
	if metadata is String:
		ability_key = metadata
	variant_human_bonus_choices[slot] = ability_key

	_apply_variant_human_bonus_modifiers()
	_revalidate_selected_feat()
	_recalculate_character_hp()
	_refresh_feat_ui()
	_refresh_ability_scores_ui()
	_update_next_button_state()
	_refresh_preview()


func _ensure_current_character() -> void:
	if CharacterCreationManager.current_character == null:
		CharacterCreationManager.current_character = CharacterSheetResource.new()
	_ensure_base_ability_scores(CharacterCreationManager.current_character)


func _ensure_base_ability_scores(character: CharacterSheetResource) -> void:
	if character == null:
		return

	for ability_key in ABILITY_ORDER:
		if not character.base_ability_scores.has(ability_key):
			character.base_ability_scores[ability_key] = 8


func _sync_selected_state_from_manager() -> void:
	if CharacterCreationManager.current_character == null:
		return

	_ensure_base_ability_scores(CharacterCreationManager.current_character)
	selected_race = CharacterCreationManager.current_character.race
	selected_class = CharacterCreationManager.current_character.class_resource
	selected_background = CharacterCreationManager.current_character.background
	if not CharacterCreationManager.current_character.feats.is_empty():
		selected_feat = CharacterCreationManager.current_character.feats[0]
	_sync_variant_human_choices_from_character()
	_revalidate_selected_feat()
	_recalculate_character_hp()


func _recalculate_character_hp() -> void:
	var character := CharacterCreationManager.current_character
	if character == null or character.class_resource == null:
		return

	var con_modifier := AbilitySystem.get_modifier(_get_final_ability_score(character, character.race, "con"))
	var racial_hp_adjustment := _get_racial_modifier_total(character.race, StatModifier.Type.HP)
	var additional_hp_adjustment := _get_character_modifier_total(character, StatModifier.Type.HP)
	character.current_hp = character.class_resource.hit_points_at_1st_level + con_modifier + racial_hp_adjustment + additional_hp_adjustment


func _revalidate_selected_feat() -> void:
	if selected_feat == null:
		selected_feat_valid = false
		selected_feat_validation_message = ""
		_apply_selected_feat_to_character()
		return

	var validation := _validate_feat_selection(selected_feat)
	selected_feat_valid = validation["valid"]
	selected_feat_validation_message = validation["message"]
	_apply_selected_feat_to_character()


func _can_advance_from_background_step() -> bool:
	return selected_class != null and selected_background != null


func _can_advance_from_feats_step() -> bool:
	if _is_variant_human_selected():
		return selected_feat != null and selected_feat_valid and _has_valid_variant_human_bonus_choices()

	if selected_feat == null:
		return true

	return selected_feat_valid


func _is_selected_race(race: RaceResource) -> bool:
	return selected_race != null and race.resource_id == selected_race.resource_id


func _is_selected_class(class_resource: ClassResource) -> bool:
	return selected_class != null and class_resource.resource_id == selected_class.resource_id


func _is_selected_background(background: BackgroundResource) -> bool:
	return selected_background != null and background.resource_id == selected_background.resource_id


func _is_selected_feat(feat: FeatResource) -> bool:
	return selected_feat != null and feat.resource_id == selected_feat.resource_id


func _format_race_summary(race: RaceResource) -> String:
	var summary_parts: Array[String] = []
	var ability_summary := _format_ability_bonus_summary(race)
	if not ability_summary.is_empty():
		summary_parts.append(ability_summary)
	summary_parts.append("Speed %d ft" % race.speed)
	if race.darkvision:
		summary_parts.append("Darkvision")
	return " | ".join(summary_parts)


func _format_class_card_summary(class_resource: ClassResource) -> String:
	var summary_parts: Array[String] = []
	var save_summary := _format_saving_throw_proficiencies(class_resource)
	if not save_summary.is_empty():
		summary_parts.append("Saves: %s" % save_summary)
	if class_resource.skill_proficiency_count > 0:
		summary_parts.append("Skills: choose %d" % class_resource.skill_proficiency_count)
	if not class_resource.armor_proficiencies.is_empty():
		summary_parts.append("Armor: %s" % ", ".join(class_resource.armor_proficiencies))
	if not class_resource.weapon_proficiencies.is_empty():
		summary_parts.append("Weapons: %s" % ", ".join(class_resource.weapon_proficiencies))
	return " | ".join(summary_parts)


func _format_ability_bonus_summary(race: RaceResource) -> String:
	var bonus_parts: Array[String] = []
	for ability_key in ABILITY_ORDER:
		var bonus := int(race.ability_increases.get(ability_key, 0))
		if bonus <= 0:
			continue
		bonus_parts.append("%s +%d" % [ABILITY_LABELS[ability_key], bonus])
	return ", ".join(bonus_parts)


func _format_feat_prerequisites(feat: FeatResource) -> String:
	return feat.prerequisites if not feat.prerequisites.strip_edges().is_empty() else "None"


func _format_feat_ability_score_increases(feat: FeatResource) -> String:
	var increases: Array[String] = []
	for modifier in feat.modifiers:
		if modifier == null:
			continue
		if modifier.modifier_type != StatModifier.Type.ABILITY_SCORE:
			continue
		if not ABILITY_LABELS.has(modifier.target_key):
			continue
		increases.append("%s %s" % [ABILITY_LABELS[modifier.target_key], _format_signed_value(modifier.value)])
	return ", ".join(increases) if not increases.is_empty() else "None"


func _format_race_preview(race: RaceResource) -> String:
	if race == null:
		return "-"

	var preview_parts: Array[String] = [race.display_name]
	var ability_summary := _format_ability_bonus_summary(race)
	if not ability_summary.is_empty():
		preview_parts.append(ability_summary)
	preview_parts.append("Speed %d ft" % race.speed)
	if race.darkvision:
		preview_parts.append("Darkvision")
	return " | ".join(preview_parts)


func _format_class_preview(character: CharacterSheetResource) -> String:
	if character == null or character.class_resource == null:
		return "-"

	var class_resource := character.class_resource
	var preview_parts: Array[String] = [class_resource.display_name, "Hit Die %s" % class_resource.hit_die]
	var save_summary := _format_saving_throw_proficiencies(class_resource)
	if not save_summary.is_empty():
		preview_parts.append("Saves: %s" % save_summary)
	if class_resource.skill_proficiency_count > 0:
		preview_parts.append("Skills: choose %d" % class_resource.skill_proficiency_count)
	return " | ".join(preview_parts)


func _format_background_preview(character: CharacterSheetResource) -> String:
	if character == null or character.background == null:
		if selected_feat != null and selected_feat_valid:
			return "Feat: %s" % selected_feat.display_name
		return "-"

	var background := character.background
	var preview_parts: Array[String] = [background.display_name]
	var skill_names := _get_skill_names(background.skill_proficiencies)
	if not skill_names.is_empty():
		preview_parts.append("Skills: %s" % ", ".join(skill_names))
	if selected_feat != null and selected_feat_valid:
		preview_parts.append("Feat: %s" % selected_feat.display_name)
	return " | ".join(preview_parts)


func _format_hp_preview(character: CharacterSheetResource, race: RaceResource) -> String:
	if character == null:
		return "10"

	if character.class_resource == null:
		var racial_hp_adjustment := _get_racial_modifier_total(race, StatModifier.Type.HP)
		var feat_hp_adjustment := _get_character_modifier_total(character, StatModifier.Type.HP)
		if racial_hp_adjustment == 0 and feat_hp_adjustment == 0:
			return str(character.current_hp)
		var pre_class_parts: Array[String] = []
		if racial_hp_adjustment != 0:
			pre_class_parts.append("%s racial" % _format_signed_value(racial_hp_adjustment))
		if feat_hp_adjustment != 0:
			pre_class_parts.append("%s feat" % _format_signed_value(feat_hp_adjustment))
		return "%d (%s)" % [character.current_hp, ", ".join(pre_class_parts)]

	var con_modifier := AbilitySystem.get_modifier(_get_final_ability_score(character, race, "con"))
	var racial_hp_adjustment := _get_racial_modifier_total(race, StatModifier.Type.HP)
	var feat_hp_adjustment := _get_character_modifier_total(character, StatModifier.Type.HP)
	var preview_parts: Array[String] = ["%s class" % character.class_resource.hit_die, "CON %s" % _format_signed_value(con_modifier)]
	if racial_hp_adjustment != 0:
		preview_parts.append("racial %s" % _format_signed_value(racial_hp_adjustment))
	if feat_hp_adjustment != 0:
		preview_parts.append("feat %s" % _format_signed_value(feat_hp_adjustment))
	return "%d (%s)" % [character.current_hp, ", ".join(preview_parts)]


func _format_ability_preview(character: CharacterSheetResource, race: RaceResource, ability_key: String) -> String:
	var total_score := _get_final_ability_score(character, race, ability_key)
	var total_bonus := _get_total_ability_bonus(character, race, ability_key)
	if total_bonus == 0:
		return str(total_score)
	return "%d (%s total)" % [total_score, _format_signed_value(total_bonus)]


func _format_saving_throw_proficiencies(class_resource: ClassResource) -> String:
	var labels: Array[String] = []
	for ability_key in class_resource.saving_throw_proficiencies:
		labels.append(ABILITY_LABELS.get(ability_key, ability_key.to_upper()))
	return ", ".join(labels)


func _get_skill_names(skill_ids: Array[String]) -> Array[String]:
	var skill_names: Array[String] = []
	for skill_id in skill_ids:
		skill_names.append(_get_skill_display_name(skill_id))
	return skill_names


func _get_skill_display_name(skill_id: String) -> String:
	if skill_name_cache.has(skill_id):
		return skill_name_cache[skill_id]

	var resource_path := "%s/%s.tres" % [SKILL_DATA_PATH, skill_id]
	var skill_resource := load(resource_path) as SkillResource
	var display_name := skill_id.trim_prefix("skill_").replace("_", " ")
	if skill_resource != null and not skill_resource.display_name.is_empty():
		display_name = skill_resource.display_name

	skill_name_cache[skill_id] = display_name
	return display_name


func _calculate_point_buy_total() -> int:
	var character := CharacterCreationManager.current_character
	if character == null:
		return 0

	var total := 0
	for ability_key in ABILITY_ORDER:
		var score := int(character.base_ability_scores.get(ability_key, 8))
		total += AbilitySystem.get_point_buy_cost(score)
	return total


func _get_racial_ability_bonus(race: RaceResource, ability_key: String) -> int:
	if race == null:
		return 0
	return int(race.ability_increases.get(ability_key, 0))


func _get_total_ability_bonus(character: CharacterSheetResource, race: RaceResource, ability_key: String) -> int:
	return _get_racial_ability_bonus(race, ability_key) + _get_character_modifier_total(character, StatModifier.Type.ABILITY_SCORE, ability_key)


func _get_final_ability_score(character: CharacterSheetResource, race: RaceResource, ability_key: String) -> int:
	if character == null:
		return 8 + _get_total_ability_bonus(character, race, ability_key)
	return int(character.base_ability_scores.get(ability_key, 8)) + _get_total_ability_bonus(character, race, ability_key)


func _get_racial_modifier_total(race: RaceResource, modifier_type: StatModifier.Type) -> int:
	if race == null:
		return 0

	var total := 0
	for modifier in race.modifiers:
		if modifier.modifier_type == modifier_type:
			total += modifier.value
	return total


func _get_character_modifier_total(character: CharacterSheetResource, modifier_type: StatModifier.Type, target_key: String = "") -> int:
	if character == null:
		return 0

	var total := 0
	for modifier in character.modifiers:
		if modifier == null:
			continue
		if modifier.modifier_type != modifier_type:
			continue
		if not target_key.is_empty() and modifier.target_key != target_key:
			continue
		total += modifier.value
	return total


func _get_character_name(character: CharacterSheetResource) -> String:
	if character == null or character.character_name.is_empty():
		return "-"
	return character.character_name


func _is_variant_human_selected() -> bool:
	return selected_race != null and selected_race.resource_id == "race_human_variant"


func _sync_variant_human_choices_from_character() -> void:
	variant_human_bonus_choices = ["", ""]
	var character := CharacterCreationManager.current_character
	if character == null:
		return

	for modifier in character.modifiers:
		if modifier == null:
			continue
		if not modifier.source.begins_with(UI_VARIANT_HUMAN_MODIFIER_SOURCE_PREFIX):
			continue
		var slot_text := modifier.source.trim_prefix(UI_VARIANT_HUMAN_MODIFIER_SOURCE_PREFIX)
		var slot := int(slot_text)
		if slot >= 0 and slot < variant_human_bonus_choices.size():
			variant_human_bonus_choices[slot] = modifier.target_key


func _sync_variant_human_selector_values() -> void:
	_select_variant_human_option(variant_human_bonus_one, variant_human_bonus_choices[0])
	_select_variant_human_option(variant_human_bonus_two, variant_human_bonus_choices[1])


func _select_variant_human_option(selector: OptionButton, ability_key: String) -> void:
	for index in range(selector.item_count):
		if selector.get_item_metadata(index) == ability_key:
			selector.select(index)
			return
	selector.select(0)


func _update_variant_human_status() -> void:
	if not _is_variant_human_selected():
		return

	if _has_valid_variant_human_bonus_choices():
		variant_human_status_label.text = "Variant Human bonuses: %s and %s." % [ABILITY_LABELS[variant_human_bonus_choices[0]], ABILITY_LABELS[variant_human_bonus_choices[1]]]
		_set_label_color(variant_human_status_label, Color(0.2, 0.7, 0.3))
	elif variant_human_bonus_choices[0].is_empty() or variant_human_bonus_choices[1].is_empty():
		variant_human_status_label.text = "Choose two different abilities for your +1 bonuses."
		_set_label_color(variant_human_status_label, Color(0.85, 0.65, 0.2))
	else:
		variant_human_status_label.text = "Variant Human bonuses must target two different abilities."
		_set_label_color(variant_human_status_label, Color(0.85, 0.25, 0.25))


func _update_feat_status() -> void:
	if selected_feat == null:
		if _is_variant_human_selected():
			feat_status_label.text = "Variant Human requires a feat selection."
			_set_label_color(feat_status_label, Color(0.85, 0.65, 0.2))
		else:
			feat_status_label.text = "No feat selected. You can skip this step."
			_set_label_color(feat_status_label, Color(0.7, 0.7, 0.7))
		return

	if selected_feat_valid:
		feat_status_label.text = "Selected feat: %s" % selected_feat.display_name
		_set_label_color(feat_status_label, Color(0.2, 0.7, 0.3))
	else:
		feat_status_label.text = selected_feat_validation_message if not selected_feat_validation_message.is_empty() else "Selected feat does not meet its prerequisites."
		_set_label_color(feat_status_label, Color(0.85, 0.25, 0.25))


func _has_valid_variant_human_bonus_choices() -> bool:
	return not variant_human_bonus_choices[0].is_empty() and not variant_human_bonus_choices[1].is_empty() and variant_human_bonus_choices[0] != variant_human_bonus_choices[1]


func _apply_variant_human_bonus_modifiers() -> void:
	var character := CharacterCreationManager.current_character
	if character == null:
		return

	_remove_character_modifiers_by_source_prefix(UI_VARIANT_HUMAN_MODIFIER_SOURCE_PREFIX)
	if not _is_variant_human_selected():
		return

	var applied := {}
	for slot in range(variant_human_bonus_choices.size()):
		var ability_key: String = variant_human_bonus_choices[slot]
		if ability_key.is_empty() or applied.has(ability_key):
			continue

		var modifier := StatModifier.new()
		modifier.modifier_type = StatModifier.Type.ABILITY_SCORE
		modifier.target_key = ability_key
		modifier.value = 1
		modifier.source = "%s%d" % [UI_VARIANT_HUMAN_MODIFIER_SOURCE_PREFIX, slot]
		character.modifiers.append(modifier)
		applied[ability_key] = true


func _apply_selected_feat_to_character() -> void:
	var character := CharacterCreationManager.current_character
	if character == null:
		return

	character.feats.clear()
	_remove_character_modifiers_by_source_prefix(UI_FEAT_MODIFIER_SOURCE_PREFIX)

	if selected_feat == null or not selected_feat_valid:
		return

	character.feats.append(selected_feat)
	for index in range(selected_feat.modifiers.size()):
		var modifier := selected_feat.modifiers[index]
		if modifier == null:
			continue

		var copied_modifier := StatModifier.new()
		copied_modifier.modifier_type = modifier.modifier_type
		copied_modifier.target_key = modifier.target_key
		copied_modifier.value = modifier.value
		copied_modifier.source = "%s%s_%d" % [UI_FEAT_MODIFIER_SOURCE_PREFIX, selected_feat.resource_id, index]
		copied_modifier.condition = modifier.condition
		character.modifiers.append(copied_modifier)


func _remove_character_modifiers_by_source_prefix(source_prefix: String) -> void:
	var character := CharacterCreationManager.current_character
	if character == null:
		return

	for index in range(character.modifiers.size() - 1, -1, -1):
		var modifier := character.modifiers[index]
		if modifier != null and modifier.source.begins_with(source_prefix):
			character.modifiers.remove_at(index)


func _validate_feat_selection(feat: FeatResource) -> Dictionary:
	if feat == null:
		return {"valid": false, "message": "No feat selected."}

	var prerequisite_text := feat.prerequisites.strip_edges()
	if prerequisite_text.is_empty():
		return {"valid": true, "message": "Selected feat: %s" % feat.display_name}

	for clause in prerequisite_text.split(",", false):
		var validation := _validate_prerequisite_clause(clause.strip_edges())
		if not validation["valid"]:
			return validation

	return {"valid": true, "message": "Selected feat: %s" % feat.display_name}


func _validate_prerequisite_clause(clause: String) -> Dictionary:
	if clause.is_empty():
		return {"valid": true, "message": ""}

	var ability_regex := RegEx.new()
	ability_regex.compile("(?i)(strength|dexterity|constitution|intelligence|wisdom|charisma)\\s*(\\d+)")
	var ability_match := ability_regex.search(clause)
	if ability_match:
		var ability_name := ability_match.get_string(1).to_lower()
		var required_score := int(ability_match.get_string(2))
		var ability_key_map := {
			"strength": "str",
			"dexterity": "dex",
			"constitution": "con",
			"intelligence": "int",
			"wisdom": "wis",
			"charisma": "cha",
		}
		var ability_key: String = ability_key_map[ability_name]
		var current_score := _get_final_ability_score(CharacterCreationManager.current_character, selected_race, ability_key)
		if current_score < required_score:
			return {"valid": false, "message": "%s requires %s %d." % [clause, ABILITY_LABELS[ability_key], required_score]}
		return {"valid": true, "message": ""}

	var class_regex := RegEx.new()
	class_regex.compile("(?i)([a-z ]+)\\s+level\\s+(\\d+)")
	var class_match := class_regex.search(clause)
	if class_match:
		var required_class_name := class_match.get_string(1).strip_edges().to_lower()
		var required_level := int(class_match.get_string(2))
		if selected_class == null:
			return {"valid": false, "message": "%s requires a class selection." % clause}
		var class_name_matches := selected_class.display_name.to_lower() == required_class_name or selected_class.resource_id.replace("class_", "").replace("_", " ") == required_class_name
		if not class_name_matches or CharacterCreationManager.current_character.current_level < required_level:
			return {"valid": false, "message": "%s requires %s level %d." % [clause, selected_class.display_name, required_level]}
		return {"valid": true, "message": ""}

	return {"valid": true, "message": ""}


func _format_signed_value(value: int) -> String:
	if value >= 0:
		return "+%d" % value
	return str(value)


func _set_label_color(label: Label, color: Color) -> void:
	label.add_theme_color_override("font_color", color)


func _get_resource_color(resource_id: String) -> Color:
	var hue := float(abs(resource_id.hash()) % 360) / 360.0
	return Color.from_hsv(hue, 0.45, 0.85, 1.0)
