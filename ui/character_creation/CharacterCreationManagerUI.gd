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
const SKILL_DATA_PATH := "res://data/skills"
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
@onready var class_selection_scroll: ScrollContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/ClassBackgroundStepContainer/ClassSelectionScroll
@onready var background_section: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/ClassBackgroundStepContainer/BackgroundSection
@onready var race_list_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/RaceStepContainer/RaceSelectionScroll/RaceList
@onready var class_list_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/ClassBackgroundStepContainer/ClassSelectionScroll/ClassList
@onready var background_list_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/ClassBackgroundStepContainer/BackgroundSection/BackgroundSelectionScroll/BackgroundList
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
var race_buttons := []
var class_buttons := []
var background_buttons := []
var selected_race: RaceResource = null
var selected_class: ClassResource = null
var selected_background: BackgroundResource = null
var skill_name_cache := {}


func _ready() -> void:
	_bind_step_buttons()
	_bind_main_area_actions()
	_ensure_current_character()
	_load_available_races()
	_load_available_classes()
	_load_available_backgrounds()
	_sync_selected_state_from_manager()
	_update_step_buttons()
	_update_main_content()
	_update_selection_buttons()
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


func _update_step_buttons() -> void:
	for index in range(step_buttons_container.get_child_count()):
		var button := step_buttons_container.get_child(index) as Button
		if button == null:
			continue
		button.button_pressed = index == current_step


func _update_main_content() -> void:
	race_step_container.visible = current_step == 0
	class_background_step_container.visible = current_step == 1 or current_step == 2
	class_selection_scroll.visible = current_step == 1
	background_section.visible = current_step == 2
	next_button.visible = current_step == 0 or current_step == 1 or current_step == 2

	match current_step:
		0:
			current_step_content_label.text = "Race Selection"
		1:
			current_step_content_label.text = "Class Selection"
		2:
			current_step_content_label.text = "Background Selection"
		_:
			current_step_content_label.text = "Current Step Content"


func _update_selection_buttons() -> void:
	_update_race_buttons()
	_update_class_buttons()
	_update_background_buttons()


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


func _update_next_button_state() -> void:
	match current_step:
		0:
			next_button.disabled = selected_race == null
		1:
			next_button.disabled = selected_class == null
		2:
			next_button.disabled = not _can_advance_from_background_step()
		_:
			next_button.disabled = true


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
	_ensure_current_character()
	CharacterCreationManager.current_character.race = selected_race
	_recalculate_character_hp()
	_update_selection_buttons()
	_update_next_button_state()
	_refresh_preview()


func _on_class_selected(index: int) -> void:
	if index < 0 or index >= available_classes.size():
		return

	selected_class = available_classes[index] as ClassResource
	_ensure_current_character()
	CharacterCreationManager.current_character.class_resource = selected_class
	_recalculate_character_hp()
	_update_main_content()
	_update_selection_buttons()
	_update_next_button_state()
	_refresh_preview()


func _on_background_selected(index: int) -> void:
	if index < 0 or index >= available_backgrounds.size():
		return

	selected_background = available_backgrounds[index] as BackgroundResource
	_ensure_current_character()
	CharacterCreationManager.current_character.background = selected_background
	_update_selection_buttons()
	_update_next_button_state()
	_refresh_preview()


func _ensure_current_character() -> void:
	if CharacterCreationManager.current_character == null:
		CharacterCreationManager.current_character = CharacterSheetResource.new()


func _sync_selected_state_from_manager() -> void:
	if CharacterCreationManager.current_character == null:
		return

	selected_race = CharacterCreationManager.current_character.race
	selected_class = CharacterCreationManager.current_character.class_resource
	selected_background = CharacterCreationManager.current_character.background
	_recalculate_character_hp()


func _recalculate_character_hp() -> void:
	var character := CharacterCreationManager.current_character
	if character == null or character.class_resource == null:
		return

	var con_score := int(character.base_ability_scores.get("con", 8))
	if character.race != null:
		con_score += int(character.race.ability_increases.get("con", 0))

	var con_modifier := AbilitySystem.get_modifier(con_score)
	var racial_hp_adjustment := _get_racial_modifier_total(character.race, StatModifier.Type.HP)
	character.current_hp = character.class_resource.hit_points_at_1st_level + con_modifier + racial_hp_adjustment


func _can_advance_from_background_step() -> bool:
	return selected_class != null and selected_background != null


func _is_selected_race(race: RaceResource) -> bool:
	return selected_race != null and race.resource_id == selected_race.resource_id


func _is_selected_class(class_resource: ClassResource) -> bool:
	return selected_class != null and class_resource.resource_id == selected_class.resource_id


func _is_selected_background(background: BackgroundResource) -> bool:
	return selected_background != null and background.resource_id == selected_background.resource_id


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
	var preview_parts: Array[String] = [
		class_resource.display_name,
		"Hit Die %s" % class_resource.hit_die,
	]

	var save_summary := _format_saving_throw_proficiencies(class_resource)
	if not save_summary.is_empty():
		preview_parts.append("Saves: %s" % save_summary)

	if class_resource.skill_proficiency_count > 0:
		preview_parts.append("Skills: choose %d" % class_resource.skill_proficiency_count)

	return " | ".join(preview_parts)


func _format_background_preview(character: CharacterSheetResource) -> String:
	if character == null or character.background == null:
		return "-"

	var background := character.background
	var preview_parts: Array[String] = [background.display_name]
	var skill_names := _get_skill_names(background.skill_proficiencies)
	if not skill_names.is_empty():
		preview_parts.append("Skills: %s" % ", ".join(skill_names))
	return " | ".join(preview_parts)


func _format_hp_preview(character: CharacterSheetResource, race: RaceResource) -> String:
	if character == null:
		return "10"

	if character.class_resource == null:
		var racial_hp_adjustment := _get_racial_modifier_total(race, StatModifier.Type.HP)
		if racial_hp_adjustment == 0:
			return str(character.current_hp)
		return "%d (%s racial)" % [character.current_hp, _format_signed_value(racial_hp_adjustment)]

	var con_score := int(character.base_ability_scores.get("con", 8))
	if race != null:
		con_score += int(race.ability_increases.get("con", 0))

	var con_modifier := AbilitySystem.get_modifier(con_score)
	var racial_hp_adjustment := _get_racial_modifier_total(race, StatModifier.Type.HP)
	var preview_parts: Array[String] = ["%s class" % character.class_resource.hit_die]
	preview_parts.append("CON %s" % _format_signed_value(con_modifier))
	if racial_hp_adjustment != 0:
		preview_parts.append("racial %s" % _format_signed_value(racial_hp_adjustment))

	return "%d (%s)" % [character.current_hp, ", ".join(preview_parts)]


func _format_ability_preview(character: CharacterSheetResource, race: RaceResource, ability_key: String) -> String:
	var base_score := 8
	if character != null:
		base_score = int(character.base_ability_scores.get(ability_key, 8))

	var racial_bonus := 0
	if race != null:
		racial_bonus = int(race.ability_increases.get(ability_key, 0))

	var total_score := base_score + racial_bonus
	if racial_bonus == 0:
		return str(total_score)
	return "%d (%s racial)" % [total_score, _format_signed_value(racial_bonus)]


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


func _get_racial_modifier_total(race: RaceResource, modifier_type: StatModifier.Type) -> int:
	if race == null:
		return 0

	var total := 0
	for modifier in race.modifiers:
		if modifier.modifier_type == modifier_type:
			total += modifier.value
	return total


func _get_character_name(character: CharacterSheetResource) -> String:
	if character == null or character.character_name.is_empty():
		return "-"
	return character.character_name


func _format_signed_value(value: int) -> String:
	if value >= 0:
		return "+%d" % value
	return str(value)


func _get_resource_color(resource_id: String) -> Color:
	var hue := float(abs(resource_id.hash()) % 360) / 360.0
	return Color.from_hsv(hue, 0.45, 0.85, 1.0)
