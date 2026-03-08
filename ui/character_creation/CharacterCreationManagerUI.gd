extends Control

signal step_changed(new_step)

const DEFAULT_STEP_NAMES := [
	"Race",
	"Class",
	"Background",
	"Skills",
	"Abilities",
	"Feats",
	"Spells",
	"Equipment",
	"Summary",
]
const RACE_DATA_PATH := "res://data/races"
const CLASS_DATA_PATH := "res://data/classes"
const BACKGROUND_DATA_PATH := "res://data/backgrounds"
const FEAT_DATA_PATH := "res://data/feats"
const SPELL_DATA_PATH := "res://data/spells"
const ITEM_DATA_PATH := "res://data/items"
const SKILL_DATA_PATH := "res://data/skills"
const PORTRAIT_ROOT_PATH := "res://assets/portraits"
const SUPPORTED_PORTRAIT_EXTENSIONS := ["png", "webp", "jpg", "jpeg", "jiff", "jfif"]
const PORTRAIT_EXTENSION_PRIORITY := {
	"png": 0,
	"webp": 1,
	"jpg": 2,
	"jpeg": 3,
	"jiff": 4,
	"jfif": 5,
	"": 99,
}
const UI_VARIANT_HUMAN_MODIFIER_SOURCE_PREFIX := "ui_variant_human_bonus_"
const UI_FEAT_MODIFIER_SOURCE_PREFIX := "ui_feat_modifier_"
const FEAT_MAGIC_INITIATE_ID := "feat_magic_initiate"
const SPELL_PHASE_CLASS_CANTRIPS := "class_cantrips"
const SPELL_PHASE_CLASS_LEVEL_ONE := "class_level_one"
const SPELL_PHASE_BONUS_CANTRIPS := "bonus_cantrips"
const SPELL_PHASE_BONUS_LEVEL_ONE := "bonus_level_one"
const ABILITY_ORDER := ["str", "dex", "con", "int", "wis", "cha"]
const MAIN_SELECTION_CARD_MIN_WIDTH := 320
const MAIN_SELECTION_CARD_MIN_HEIGHT := 184
const FEAT_SELECTION_CARD_MIN_HEIGHT := 136
const SPELL_SELECTION_CARD_MIN_WIDTH := 292
const SPELL_SELECTION_CARD_MIN_HEIGHT := 170
const GRID_SPACING_MAIN := 12
const GRID_SPACING_SPELL := 10
const GRID_MAX_COLUMNS_MAIN := 3
const GRID_MAX_COLUMNS_SPELL := 2
const MAIN_SELECTION_PREVIEW_SIZE := Vector2(96, 96)
const SPELL_SELECTION_PREVIEW_SIZE := Vector2(64, 64)
const ABILITY_LABELS := {
	"str": "STR",
	"dex": "DEX",
	"con": "CON",
	"int": "INT",
	"wis": "WIS",
	"cha": "CHA",
}

@onready var current_step_content_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/CurrentStepContentLabel
@onready var left_sidebar: PanelContainer = $RootMargin/ThreePanelLayout/LeftSidebar
@onready var right_preview_panel: PanelContainer = $RootMargin/ThreePanelLayout/RightPreviewPanel
@onready var race_step_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/RaceStepContainer
@onready var class_background_step_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/ClassBackgroundStepContainer
@onready var skills_step_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SkillsStepContainer
@onready var abilities_step_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/AbilitiesStepContainer
@onready var feats_step_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer
@onready var spells_step_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer
@onready var equipment_step_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/EquipmentStepContainer
@onready var summary_step_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SummaryStepContainer
@onready var class_selection_scroll: ScrollContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/ClassBackgroundStepContainer/ClassSelectionScroll
@onready var background_section: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/ClassBackgroundStepContainer/BackgroundSection
@onready var race_list_container: GridContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/RaceStepContainer/RaceSelectionScroll/RaceList
@onready var class_list_container: GridContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/ClassBackgroundStepContainer/ClassSelectionScroll/ClassList
@onready var background_list_container: GridContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/ClassBackgroundStepContainer/BackgroundSection/BackgroundSelectionScroll/BackgroundList
@onready var automatic_skills_list_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SkillsStepContainer/AutomaticSkillsPanel/AutomaticSkillsMargin/AutomaticSkillsContent/AutomaticSkillsList
@onready var choose_skills_panel: PanelContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SkillsStepContainer/ChooseSkillsPanel
@onready var skills_status_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SkillsStepContainer/ChooseSkillsPanel/ChooseSkillsMargin/ChooseSkillsContent/SkillsStatusLabel
@onready var choose_skills_list_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SkillsStepContainer/ChooseSkillsPanel/ChooseSkillsMargin/ChooseSkillsContent/ChooseSkillsScroll/ChooseSkillsList
@onready var ability_rows_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/AbilitiesStepContainer/AbilitiesScroll/AbilityRows
@onready var points_spent_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/AbilitiesStepContainer/PointBuySummaryPanel/PointBuySummaryMargin/PointBuySummaryContent/PointsSpentLabel
@onready var points_remaining_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/AbilitiesStepContainer/PointBuySummaryPanel/PointBuySummaryMargin/PointBuySummaryContent/PointsRemainingLabel
@onready var point_buy_status_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/AbilitiesStepContainer/PointBuySummaryPanel/PointBuySummaryMargin/PointBuySummaryContent/PointBuyStatusLabel
@onready var variant_human_panel: PanelContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/VariantHumanPanel
@onready var variant_human_bonus_one: OptionButton = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/VariantHumanPanel/VariantHumanMargin/VariantHumanContent/VariantHumanSelectors/VariantHumanBonusOne
@onready var variant_human_bonus_two: OptionButton = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/VariantHumanPanel/VariantHumanMargin/VariantHumanContent/VariantHumanSelectors/VariantHumanBonusTwo
@onready var variant_human_status_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/VariantHumanPanel/VariantHumanMargin/VariantHumanContent/VariantHumanStatusLabel
@onready var feat_status_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/FeatStatusLabel
@onready var magic_initiate_panel: PanelContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/MagicInitiatePanel
@onready var magic_initiate_description_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/MagicInitiatePanel/MagicInitiateMargin/MagicInitiateContent/MagicInitiateDescriptionLabel
@onready var magic_initiate_feat_spell_list_option: OptionButton = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/MagicInitiatePanel/MagicInitiateMargin/MagicInitiateContent/MagicInitiateFeatSpellList
@onready var feat_list_container: GridContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/FeatsSelectionScroll/FeatList
@onready var feat_details_dialog: AcceptDialog = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/FeatDetailsDialog
@onready var feat_details_title_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/FeatDetailsDialog/FeatDetailsMargin/FeatDetailsScroll/FeatDetailsContent/FeatDetailsTitle
@onready var feat_details_status_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/FeatDetailsDialog/FeatDetailsMargin/FeatDetailsScroll/FeatDetailsContent/FeatDetailsStatus
@onready var feat_details_select_button: Button = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/FeatDetailsDialog/FeatDetailsMargin/FeatDetailsScroll/FeatDetailsContent/FeatDetailsActionRow/FeatDetailsSelectButton
@onready var feat_details_prereq_value_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/FeatDetailsDialog/FeatDetailsMargin/FeatDetailsScroll/FeatDetailsContent/FeatDetailsPrereqValue
@onready var feat_details_description_value_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/FeatDetailsDialog/FeatDetailsMargin/FeatDetailsScroll/FeatDetailsContent/FeatDetailsDescriptionValue
@onready var feat_details_mechanics_value: RichTextLabel = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/FeatDetailsDialog/FeatDetailsMargin/FeatDetailsScroll/FeatDetailsContent/FeatDetailsMechanicsValue
@onready var feat_replace_dialog: ConfirmationDialog = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/FeatReplaceDialog
@onready var feat_replace_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/FeatReplaceDialog/FeatReplaceMargin/FeatReplaceContent/FeatReplaceLabel
@onready var feat_replace_option: OptionButton = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/FeatReplaceDialog/FeatReplaceMargin/FeatReplaceContent/FeatReplaceOption
@onready var feat_replace_cancel_button: Button = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/FeatReplaceDialog/FeatReplaceMargin/FeatReplaceContent/FeatReplaceActions/FeatReplaceCancelButton
@onready var feat_replace_confirm_button: Button = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/FeatsStepContainer/FeatReplaceDialog/FeatReplaceMargin/FeatReplaceContent/FeatReplaceActions/FeatReplaceConfirmButton
@onready var spell_status_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/SpellStatusLabel
@onready var no_spells_required_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/NoSpellsRequiredLabel
@onready var spell_picker_panel: PanelContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/SpellPickerPanel
@onready var spell_phase_rail: HBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/SpellPickerPanel/SpellPickerMargin/SpellPickerContent/SpellPhaseRail
@onready var spell_phase_title_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/SpellPickerPanel/SpellPickerMargin/SpellPickerContent/SpellSummaryPanel/SpellSummaryMargin/SpellSummaryContent/SpellPhaseTitleLabel
@onready var spell_selection_summary_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/SpellPickerPanel/SpellPickerMargin/SpellPickerContent/SpellSummaryPanel/SpellSummaryMargin/SpellSummaryContent/SpellSelectionSummaryLabel
@onready var selected_spell_chips_container: HBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/SpellPickerPanel/SpellPickerMargin/SpellPickerContent/SpellSummaryPanel/SpellSummaryMargin/SpellSummaryContent/SelectedSpellChipsScroll/SelectedSpellChips
@onready var spell_search_line_edit: LineEdit = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/SpellPickerPanel/SpellPickerMargin/SpellPickerContent/SpellPickerSplit/SpellListColumn/SpellSearchLineEdit
@onready var spell_list_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/SpellPickerPanel/SpellPickerMargin/SpellPickerContent/SpellPickerSplit/SpellListColumn/SpellListScroll/SpellList
@onready var spell_detail_panel: PanelContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/SpellPickerPanel/SpellPickerMargin/SpellPickerContent/SpellPickerSplit/SpellDetailPanel
@onready var spell_detail_title_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/SpellPickerPanel/SpellPickerMargin/SpellPickerContent/SpellPickerSplit/SpellDetailPanel/SpellDetailMargin/SpellDetailScroll/SpellDetailContent/SpellDetailTitleLabel
@onready var spell_detail_meta_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/SpellPickerPanel/SpellPickerMargin/SpellPickerContent/SpellPickerSplit/SpellDetailPanel/SpellDetailMargin/SpellDetailScroll/SpellDetailContent/SpellDetailMetaLabel
@onready var spell_detail_rules_label: RichTextLabel = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/SpellPickerPanel/SpellPickerMargin/SpellPickerContent/SpellPickerSplit/SpellDetailPanel/SpellDetailMargin/SpellDetailScroll/SpellDetailContent/SpellDetailRulesLabel
@onready var spell_details_dialog: AcceptDialog = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/SpellDetailsDialog
@onready var spell_details_title_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/SpellDetailsDialog/SpellDetailsMargin/SpellDetailsScroll/SpellDetailsContent/SpellDetailsTitle
@onready var spell_details_meta_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/SpellDetailsDialog/SpellDetailsMargin/SpellDetailsScroll/SpellDetailsContent/SpellDetailsMeta
@onready var spell_details_rules_label: RichTextLabel = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/SpellDetailsDialog/SpellDetailsMargin/SpellDetailsScroll/SpellDetailsContent/SpellDetailsRules
@onready var class_spells_section: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/ClassSpellsSection
@onready var class_cantrips_panel: PanelContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/ClassSpellsSection/CantripsPanel
@onready var class_cantrips_counter_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/ClassSpellsSection/CantripsPanel/CantripsMargin/CantripsContent/CantripsCounterLabel
@onready var class_cantrips_list_container: GridContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/ClassSpellsSection/CantripsPanel/CantripsMargin/CantripsContent/CantripsScroll/CantripsList
@onready var class_level_one_panel: PanelContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/ClassSpellsSection/LevelOneSpellsPanel
@onready var class_level_one_counter_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/ClassSpellsSection/LevelOneSpellsPanel/LevelOneSpellsMargin/LevelOneSpellsContent/LevelOneSpellsCounterLabel
@onready var class_level_one_list_container: GridContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/ClassSpellsSection/LevelOneSpellsPanel/LevelOneSpellsMargin/LevelOneSpellsContent/LevelOneSpellsScroll/LevelOneSpellsList
@onready var feat_spells_section: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/FeatSpellsSection
@onready var feat_spells_description_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/FeatSpellsSection/FeatSpellsDescriptionLabel
@onready var feat_cantrips_panel: PanelContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/FeatSpellsSection/FeatCantripsPanel
@onready var feat_cantrips_counter_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/FeatSpellsSection/FeatCantripsPanel/FeatCantripsMargin/FeatCantripsContent/FeatCantripsCounterLabel
@onready var feat_cantrips_list_container: GridContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/FeatSpellsSection/FeatCantripsPanel/FeatCantripsMargin/FeatCantripsContent/FeatCantripsScroll/FeatCantripsList
@onready var feat_level_one_panel: PanelContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/FeatSpellsSection/FeatLevelOneSpellsPanel
@onready var feat_level_one_counter_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/FeatSpellsSection/FeatLevelOneSpellsPanel/FeatLevelOneSpellsMargin/FeatLevelOneSpellsContent/FeatLevelOneSpellsCounterLabel
@onready var feat_level_one_list_container: GridContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SpellsStepContainer/FeatSpellsSection/FeatLevelOneSpellsPanel/FeatLevelOneSpellsMargin/FeatLevelOneSpellsContent/FeatLevelOneSpellsScroll/FeatLevelOneSpellsList
@onready var use_default_gold_checkbox: CheckBox = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/EquipmentStepContainer/UseDefaultGoldCheckBox
@onready var equipment_status_label: Label = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/EquipmentStepContainer/EquipmentStatusLabel
@onready var equipment_tabs: TabContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/EquipmentStepContainer/EquipmentTabs
@onready var pack_list_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/EquipmentStepContainer/EquipmentTabs/StartingPacksTab/PacksScroll/PackList
@onready var item_search_line_edit: LineEdit = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/EquipmentStepContainer/EquipmentTabs/IndividualItemsTab/ItemSearchLineEdit
@onready var individual_items_list_container: VBoxContainer = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/EquipmentStepContainer/EquipmentTabs/IndividualItemsTab/IndividualItemsScroll/IndividualItemsList
@onready var step_buttons_container: VBoxContainer = $RootMargin/ThreePanelLayout/LeftSidebar/SidebarMargin/SidebarContent/StepButtons
@onready var previous_button: Button = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/NavigationButtons/PreviousButton
@onready var next_button: Button = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/NavigationButtons/NextButton
@onready var create_character_button: Button = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/NavigationButtons/CreateCharacterButton
@onready var summary_preview: RichTextLabel = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SummaryStepContainer/SummaryPanel/SummaryMargin/SummaryContent/SummaryScroll/SummaryScrollContent/SummaryPreview
@onready var character_name_input: LineEdit = $RootMargin/ThreePanelLayout/MainArea/MainAreaMargin/MainAreaContent/SummaryStepContainer/SummaryPanel/SummaryMargin/SummaryContent/CharacterNameRow/CharacterNameInput
@onready var character_name_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/MainPreviewSection/MainPreviewMargin/MainPreviewScroll/PreviewLabels/CharacterNamePreview
@onready var race_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/MainPreviewSection/MainPreviewMargin/MainPreviewScroll/PreviewLabels/RacePreview
@onready var class_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/MainPreviewSection/MainPreviewMargin/MainPreviewScroll/PreviewLabels/ClassPreview
@onready var background_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/MainPreviewSection/MainPreviewMargin/MainPreviewScroll/PreviewLabels/BackgroundPreview
@onready var hp_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/MainPreviewSection/MainPreviewMargin/MainPreviewScroll/PreviewLabels/HPPreview
@onready var spellcasting_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/MainPreviewSection/MainPreviewMargin/MainPreviewScroll/PreviewLabels/SpellcastingPreview
@onready var skills_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/MainPreviewSection/MainPreviewMargin/MainPreviewScroll/PreviewLabels/SkillsPreview
@onready var str_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/MainPreviewSection/MainPreviewMargin/MainPreviewScroll/PreviewLabels/STRPreview
@onready var dex_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/MainPreviewSection/MainPreviewMargin/MainPreviewScroll/PreviewLabels/DEXPreview
@onready var con_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/MainPreviewSection/MainPreviewMargin/MainPreviewScroll/PreviewLabels/CONPreview
@onready var int_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/MainPreviewSection/MainPreviewMargin/MainPreviewScroll/PreviewLabels/INTPreview
@onready var wis_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/MainPreviewSection/MainPreviewMargin/MainPreviewScroll/PreviewLabels/WISPreview
@onready var cha_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/MainPreviewSection/MainPreviewMargin/MainPreviewScroll/PreviewLabels/CHAPreview
@onready var known_spells_preview: RichTextLabel = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/SpellsSection/SpellsMargin/SpellsContent/SpellsScroll/SpellsPreviewList/KnownSpellsPreview
@onready var inventory_items_container: VBoxContainer = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/InventoryGoldSection/InventoryGoldMargin/InventoryGoldContent/InventoryGoldScroll/InventoryGoldList/InventoryItemsContainer
@onready var inventory_gold_amount_label: Label = $RootMargin/ThreePanelLayout/RightPreviewPanel/PreviewMargin/PreviewContent/InventoryGoldSection/InventoryGoldMargin/InventoryGoldContent/InventoryGoldScroll/InventoryGoldList/InventoryGoldAmountLabel

var step_names := DEFAULT_STEP_NAMES.duplicate()
var current_step := 0
var available_races := []
var available_classes := []
var available_backgrounds := []
var available_feats := []
var available_skills := []
var available_spells := []
var available_pack_items := []
var available_individual_items := []
var race_buttons := []
var class_buttons := []
var background_buttons := []
var feat_buttons := []
var pack_buttons := []
var selected_race: RaceResource = null
var selected_class: ClassResource = null
var selected_background: BackgroundResource = null
var selected_feat: FeatResource = null
var inspected_feat: FeatResource = null
var selected_feat_valid := false
var selected_feat_validation_message := ""
var variant_human_bonus_choices := ["", ""]
var selected_pack: ItemResource = null
var selected_individual_item_ids := {}
var selected_item_resources := {}
var selected_class_skill_ids := {}
var skill_resource_cache := {}
var selected_class_cantrip_ids := {}
var selected_class_level_one_spell_ids := {}
var selected_feat_cantrip_ids := {}
var selected_feat_level_one_spell_ids := {}
var magic_initiate_spell_list := ""
var spell_resource_cache := {}
var current_spell_phase := ""
var inspected_spell: SpellResource = null
var use_default_starting_gold := false
var selected_class_equipment_choice_state := {}
var selected_background_equipment_choice_state := {}
var skill_name_cache := {}
var ability_controls := {}
var selection_preview_texture_cache := {}
var portrait_file_cache := {}


func _ready() -> void:
	resized.connect(_schedule_selection_grid_layout_refresh)
	_bind_step_buttons()
	_bind_main_area_actions()
	_configure_dialog_buttons()
	_ensure_current_character()
	_load_available_races()
	_load_available_classes()
	_load_available_backgrounds()
	_load_available_feats()
	_load_available_skills()
	_load_available_spells()
	_load_available_equipment()
	_sync_selected_state_from_manager()
	_refresh_allowed_equipment_options()
	_build_ability_score_controls()
	_setup_variant_human_ability_selectors()
	_update_step_buttons()
	_update_main_content()
	_update_selection_buttons()
	_refresh_skills_ui()
	_refresh_ability_scores_ui()
	_refresh_feat_ui()
	_refresh_spells_ui()
	_refresh_equipment_ui()
	_refresh_summary_ui()
	_update_next_button_state()
	_refresh_preview()
	_announce_step_change()
	_schedule_selection_grid_layout_refresh()


func go_to_next_step() -> void:
	if current_step == 6 and _advance_spell_phase():
		return
	go_to_step(current_step + 1)


func go_to_previous_step() -> void:
	if current_step == 6:
		if _revert_current_spell_phase_and_retreat():
			return
	go_to_step(current_step - 1)


func apply_debug_test_build() -> void:
	_ensure_current_character()

	var dragonborn := _find_race_by_id("race_dragonborn")
	var sorcerer := _find_class_by_id("class_sorcerer")
	var charlatan := _find_background_by_id("background_charlatan")
	var war_caster := _find_feat_by_id("feat_war_caster")
	if dragonborn == null or sorcerer == null or charlatan == null or war_caster == null:
		push_warning("Character creation debug preset could not be applied because a required resource was missing.")
		return

	var character := CharacterCreationManager.current_character
	selected_race = dragonborn
	selected_class = sorcerer
	selected_background = charlatan
	selected_feat = war_caster
	variant_human_bonus_choices = ["", ""]
	selected_class_cantrip_ids.clear()
	selected_class_level_one_spell_ids.clear()
	selected_feat_cantrip_ids.clear()
	selected_feat_level_one_spell_ids.clear()
	magic_initiate_spell_list = ""
	selected_pack = null
	selected_individual_item_ids.clear()
	selected_class_skill_ids.clear()
	selected_class_skill_ids["skill_arcana"] = true
	selected_class_skill_ids["skill_persuasion"] = true
	use_default_starting_gold = false

	character.race = selected_race
	character.class_resource = selected_class
	character.background = selected_background
	character.current_level = 1
	_ensure_base_ability_scores(character)
	character.base_ability_scores["str"] = 15
	character.base_ability_scores["dex"] = 15
	character.base_ability_scores["con"] = 15
	character.base_ability_scores["int"] = 8
	character.base_ability_scores["wis"] = 8
	character.base_ability_scores["cha"] = 8

	_apply_variant_human_bonus_modifiers()
	_refresh_allowed_equipment_options()
	_sync_equipment_to_character()
	_revalidate_selected_feat()
	_recalculate_character_hp()
	_update_selection_buttons()
	_refresh_skills_ui()
	_refresh_feat_ui()
	_refresh_spells_ui()
	_refresh_equipment_ui()
	_refresh_ability_scores_ui()
	_update_next_button_state()
	_refresh_preview()
	go_to_step(4)
	print("Applied debug character preset: Dragonborn / Sorcerer / Charlatan / War Caster")


func go_to_step(index: int) -> void:
	if index < 0 or index >= step_names.size():
		return

	current_step = index
	if current_step == 6:
		_normalize_spell_phase()
	_update_step_buttons()
	_update_main_content()
	_refresh_skills_ui()
	_refresh_ability_scores_ui()
	_refresh_feat_ui()
	_refresh_spells_ui()
	_refresh_equipment_ui()
	_refresh_summary_ui()
	_update_next_button_state()
	if current_step == 8 and _get_character_name(CharacterCreationManager.current_character) == "-":
		character_name_input.grab_focus()
	_announce_step_change()
	step_changed.emit(step_names[current_step])


func _bind_step_buttons() -> void:
	for index in range(step_buttons_container.get_child_count()):
		var button := step_buttons_container.get_child(index) as Button
		if button == null:
			continue
		button.pressed.connect(_on_step_button_pressed.bind(index))


func _bind_main_area_actions() -> void:
	previous_button.pressed.connect(go_to_previous_step)
	next_button.pressed.connect(go_to_next_step)
	create_character_button.pressed.connect(_on_create_character_pressed)
	character_name_input.text_changed.connect(_on_character_name_changed)
	variant_human_bonus_one.item_selected.connect(_on_variant_human_bonus_selected.bind(0))
	variant_human_bonus_two.item_selected.connect(_on_variant_human_bonus_selected.bind(1))
	magic_initiate_feat_spell_list_option.item_selected.connect(_on_magic_initiate_spell_list_selected)
	feat_details_select_button.pressed.connect(_on_feat_details_select_pressed)
	feat_replace_confirm_button.pressed.connect(_on_feat_replace_confirmed)
	feat_replace_cancel_button.pressed.connect(_on_feat_replace_cancel_pressed)
	spell_search_line_edit.text_changed.connect(_on_spell_search_text_changed)
	use_default_gold_checkbox.toggled.connect(_on_use_default_gold_toggled)
	item_search_line_edit.text_changed.connect(_on_item_search_text_changed)


func _configure_dialog_buttons() -> void:
	feat_details_dialog.get_ok_button().visible = false
	feat_replace_dialog.get_ok_button().visible = false
	feat_replace_dialog.get_cancel_button().visible = false
	spell_details_dialog.get_ok_button().visible = false


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


func _load_available_skills() -> void:
	available_skills.clear()
	skill_resource_cache.clear()

	var skill_files := DirAccess.get_files_at(SKILL_DATA_PATH)
	skill_files.sort()

	for file_name in skill_files:
		if not file_name.begins_with("skill_") or not file_name.ends_with(".tres"):
			continue

		var skill := load("%s/%s" % [SKILL_DATA_PATH, file_name]) as SkillResource
		if skill == null:
			continue

		available_skills.append(skill)
		skill_resource_cache[skill.resource_id] = skill


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


func _load_available_spells() -> void:
	available_spells.clear()
	spell_resource_cache.clear()

	var spell_files := DirAccess.get_files_at(SPELL_DATA_PATH)
	spell_files.sort()

	for file_name in spell_files:
		if not file_name.begins_with("spell_") or not file_name.ends_with(".tres"):
			continue

		var spell := load("%s/%s" % [SPELL_DATA_PATH, file_name]) as SpellResource
		if spell == null:
			continue

		available_spells.append(spell)
		spell_resource_cache[spell.resource_id] = spell


func _load_available_equipment() -> void:
	available_pack_items.clear()
	available_individual_items.clear()
	pack_buttons.clear()
	selected_item_resources.clear()

	var item_files := DirAccess.get_files_at(ITEM_DATA_PATH)
	item_files.sort()

	for file_name in item_files:
		if not file_name.begins_with("item_") or not file_name.ends_with(".tres"):
			continue

		var item := load("%s/%s" % [ITEM_DATA_PATH, file_name]) as ItemResource
		if item == null:
			continue

		selected_item_resources[item.resource_id] = item

	_refresh_allowed_equipment_options()


func _refresh_allowed_equipment_options() -> void:
	available_pack_items.clear()
	available_individual_items.clear()
	pack_buttons.clear()

	for child in pack_list_container.get_children():
		child.queue_free()
	for child in individual_items_list_container.get_children():
		child.queue_free()

	selected_pack = null
	selected_individual_item_ids.clear()
	_sanitize_class_equipment_choice_state()
	_rebuild_equipment_choice_list()
	_rebuild_equipment_summary_list()


func _get_allowed_equipment_option_ids() -> Array[String]:
	var allowed_ids: Array[String] = []
	var seen := {}
	for item_id in _get_background_equipment_item_ids():
		if seen.has(item_id):
			continue
		seen[item_id] = true
		allowed_ids.append(item_id)
	for item_id in _get_class_equipment_item_ids():
		if seen.has(item_id):
			continue
		seen[item_id] = true
		allowed_ids.append(item_id)
	return allowed_ids


func _sanitize_class_equipment_choice_state() -> void:
	_sanitize_equipment_choice_state(selected_background_equipment_choice_state, _get_background_equipment_choice_groups())
	_sanitize_equipment_choice_state(selected_class_equipment_choice_state, _get_class_equipment_choice_groups())


func _sanitize_equipment_choice_state(choice_state: Dictionary, groups: Array) -> void:
	var valid_group_ids := {}
	for group in groups:
		var group_id := str(group.get("id", ""))
		if group_id.is_empty():
			continue
		valid_group_ids[group_id] = true

	var stale_group_ids: Array[String] = []
	for group_id in choice_state.keys():
		var key := str(group_id)
		if not valid_group_ids.has(key):
			stale_group_ids.append(key)
	for group_id in stale_group_ids:
		choice_state.erase(group_id)

	for group in groups:
		var group_id := str(group.get("id", ""))
		if group_id.is_empty():
			continue

		var state: Dictionary = choice_state.get(group_id, {})
		var variant_id: String = str(state.get("variant_id", ""))
		var variant: Dictionary = _find_equipment_group_variant(group, variant_id)
		var variants: Array = group.get("variants", [])
		if variant.is_empty() and variants.size() == 1 and variants[0] is Dictionary:
			variant = variants[0]
			variant_id = str(variant.get("id", ""))
		if variant.is_empty():
			choice_state.erase(group_id)
			continue

		var selection_count := int(variant.get("selection_count", 0))
		var selected_item_ids: Array[String] = []
		for selected_id in state.get("selected_item_ids", []):
			selected_item_ids.append(str(selected_id))
		if selection_count <= 0:
			selected_item_ids.clear()
		else:
			selected_item_ids.resize(selection_count)
			var valid_pool := {}
			for item_id in variant.get("pool_item_ids", []):
				valid_pool[str(item_id)] = true
			for index in range(selected_item_ids.size()):
				if not valid_pool.has(selected_item_ids[index]):
					selected_item_ids[index] = ""

		choice_state[group_id] = {
			"variant_id": variant_id,
			"selected_item_ids": selected_item_ids,
		}


func _rebuild_equipment_choice_list() -> void:
	_clear_container_children(pack_list_container)
	equipment_tabs.set_tab_title(0, "Starter Choices")
	equipment_tabs.set_tab_title(1, "Equipment Summary")
	equipment_tabs.current_tab = min(equipment_tabs.current_tab, equipment_tabs.get_tab_count() - 1)
	item_search_line_edit.visible = false

	if selected_class == null or selected_background == null:
		_add_empty_state_label(pack_list_container, "Select your class and background to configure starting equipment.")
		return

	var has_choice_groups := false
	var background_groups := _get_background_equipment_choice_groups()
	if not background_groups.is_empty():
		has_choice_groups = true
		_add_equipment_section_header(pack_list_container, "Background Equipment")
		for group in background_groups:
			pack_list_container.add_child(_build_equipment_choice_group_panel(group, "background", selected_background_equipment_choice_state))

	if use_default_starting_gold:
		var gold_label := Label.new()
		gold_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		gold_label.text = "Class starter equipment is skipped. Background equipment still applies."
		pack_list_container.add_child(gold_label)
	elif not _get_class_equipment_choice_groups().is_empty():
		has_choice_groups = true
		_add_equipment_section_header(pack_list_container, "Class Equipment")
		for group in _get_class_equipment_choice_groups():
			pack_list_container.add_child(_build_equipment_choice_group_panel(group, "class", selected_class_equipment_choice_state))

	if has_choice_groups:
		return

	if use_default_starting_gold:
		_add_empty_state_label(pack_list_container, "No starter equipment choices are required. Class starting gold and background gear are already applied.")
		return
	var choice_groups := _get_class_equipment_choice_groups()
	if choice_groups.is_empty():
		_add_empty_state_label(pack_list_container, "This class does not currently require any starter equipment choices.")
		return


func _add_equipment_section_header(container: Control, text: String) -> void:
	var header := Label.new()
	header.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header.add_theme_font_size_override("font_size", 18)
	header.text = text
	container.add_child(header)


func _build_equipment_choice_group_panel(group: Dictionary, scope: String, choice_state: Dictionary) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	panel.add_child(margin)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	margin.add_child(content)

	var title_label := Label.new()
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.text = str(group.get("title", "Starter Equipment Choice"))
	content.add_child(title_label)

	var group_id := str(group.get("id", ""))
	var state: Dictionary = choice_state.get(group_id, {})
	var selected_variant_id: String = str(state.get("variant_id", ""))
	var variants: Array = group.get("variants", [])
	if selected_variant_id.is_empty() and variants.size() == 1 and variants[0] is Dictionary:
		selected_variant_id = str((variants[0] as Dictionary).get("id", ""))

	if variants.size() > 1:
		var variant_selector := OptionButton.new()
		variant_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		variant_selector.add_item("Choose an option")
		variant_selector.set_item_metadata(0, "")
		for variant in variants:
			var option_index := variant_selector.item_count
			variant_selector.add_item(str(variant.get("label", "Option")))
			variant_selector.set_item_metadata(option_index, str(variant.get("id", "")))
			if str(variant.get("id", "")) == selected_variant_id:
				variant_selector.select(option_index)
		variant_selector.item_selected.connect(_on_equipment_group_variant_selected.bind(scope, group_id, variant_selector))
		content.add_child(variant_selector)

	var selected_variant := _find_equipment_group_variant(group, selected_variant_id)
	if selected_variant.is_empty():
		return panel

	var variant_items := Array(selected_variant.get("fixed_item_ids", []))
	if not variant_items.is_empty():
		var included_label := Label.new()
		included_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		included_label.text = "Includes: %s" % ", ".join(_get_item_display_names(variant_items))
		content.add_child(included_label)

	var selection_count := int(selected_variant.get("selection_count", 0))
	if selection_count <= 0:
		return panel

	var selected_item_ids: Array[String] = []
	for selected_id in state.get("selected_item_ids", []):
		selected_item_ids.append(str(selected_id))
	selected_item_ids.resize(selection_count)

	for slot_index in range(selection_count):
		var slot_selector := OptionButton.new()
		slot_selector.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot_selector.add_item("Choose item %d" % (slot_index + 1))
		slot_selector.set_item_metadata(0, "")
		for item_id in selected_variant.get("pool_item_ids", []):
			var option_index := slot_selector.item_count
			slot_selector.add_item(_get_item_display_name(str(item_id)))
			slot_selector.set_item_metadata(option_index, str(item_id))
			if selected_item_ids[slot_index] == str(item_id):
				slot_selector.select(option_index)
		slot_selector.item_selected.connect(_on_equipment_group_slot_selected.bind(scope, group_id, slot_index, slot_selector))
		content.add_child(slot_selector)

	var extra_item_ids := Array(selected_variant.get("extra_item_ids", []))
	if not extra_item_ids.is_empty():
		var extras_label := Label.new()
		extras_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		extras_label.text = "Also includes: %s" % ", ".join(_get_item_display_names(extra_item_ids))
		content.add_child(extras_label)

	return panel


func _rebuild_equipment_summary_list() -> void:
	_clear_container_children(individual_items_list_container)

	if selected_class == null or selected_background == null:
		_add_empty_state_label(individual_items_list_container, "Equipment summary will appear after class and background are selected.")
		return

	var mode_label := Label.new()
	mode_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	mode_label.text = "Mode: %s" % ("Starting Gold" if use_default_starting_gold else "Starter Equipment")
	individual_items_list_container.add_child(mode_label)

	var gold_label := Label.new()
	gold_label.text = "Gold: %s" % _format_gold_amount(_get_starting_gold_amount())
	individual_items_list_container.add_child(gold_label)

	var item_ids := _get_equipment_item_ids_for_character()
	if item_ids.is_empty():
		_add_empty_state_label(individual_items_list_container, "No equipment will be added yet. Choose class equipment options or use the starting gold path.")
		return

	for entry in _get_item_display_entries_for_ids(item_ids):
		var item_label := Label.new()
		item_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		item_label.text = "- %s" % entry
		individual_items_list_container.add_child(item_label)


func _get_equipment_item_ids_for_character() -> Array[String]:
	var item_ids: Array[String] = []
	item_ids.append_array(_get_background_equipment_item_ids())
	if not use_default_starting_gold:
		item_ids.append_array(_get_class_equipment_item_ids())
	return item_ids


func _get_background_equipment_item_ids() -> Array[String]:
	if selected_background == null:
		return []
	return _get_equipment_item_ids_from_spec(_get_background_equipment_spec(selected_background), selected_background_equipment_choice_state)


func _get_class_equipment_item_ids() -> Array[String]:
	if selected_class == null:
		return []
	return _get_equipment_item_ids_from_spec(_get_class_equipment_spec(selected_class), selected_class_equipment_choice_state)


func _get_equipment_item_ids_from_spec(spec: Dictionary, choice_state: Dictionary) -> Array[String]:
	var item_ids: Array[String] = []
	for item_id in spec.get("fixed_item_ids", []):
		item_ids.append(str(item_id))

	for group in spec.get("groups", []):
		var group_id := str(group.get("id", ""))
		var state: Dictionary = choice_state.get(group_id, {})
		var variant := _find_equipment_group_variant(group, str(state.get("variant_id", "")))
		if variant.is_empty():
			continue

		for item_id in variant.get("fixed_item_ids", []):
			item_ids.append(str(item_id))
		for item_id in variant.get("extra_item_ids", []):
			item_ids.append(str(item_id))
		for selected_id in state.get("selected_item_ids", []):
			var cleaned := str(selected_id)
			if not cleaned.is_empty():
				item_ids.append(cleaned)
	return item_ids


func _get_background_equipment_choice_groups() -> Array:
	if selected_background == null:
		return []
	return _get_background_equipment_spec(selected_background).get("groups", [])


func _get_class_equipment_choice_groups() -> Array:
	if selected_class == null:
		return []
	return _get_class_equipment_spec(selected_class).get("groups", [])


func _find_equipment_group_variant(group: Dictionary, variant_id: String) -> Dictionary:
	if variant_id.is_empty():
		return {}
	for variant in group.get("variants", []):
		if str(variant.get("id", "")) == variant_id:
			return variant
	return {}


func _build_equipment_variant(variant_id: String, label: String, fixed_item_ids: Array[String] = [], pool_item_ids: Array[String] = [], selection_count: int = 0, extra_item_ids: Array[String] = []) -> Dictionary:
	return {
		"id": variant_id,
		"label": label,
		"fixed_item_ids": fixed_item_ids.duplicate(),
		"pool_item_ids": pool_item_ids.duplicate(),
		"selection_count": selection_count,
		"extra_item_ids": extra_item_ids.duplicate(),
	}


func _get_background_equipment_spec(background_resource: BackgroundResource) -> Dictionary:
	if background_resource == null:
		return {"fixed_item_ids": [], "groups": []}

	var instrument_item_ids: Array[String] = _filter_existing_item_ids(["item_drum", "item_flute", "item_lute", "item_lyre"])
	var artisan_tool_item_ids: Array[String] = _filter_existing_item_ids([
		"item_alchemists_supplies",
		"item_carpenters_tools",
		"item_cooks_utensils",
		"item_glassblowers_tools",
		"item_jewelers_tools",
		"item_leatherworkers_tools",
		"item_masons_tools",
		"item_painters_supplies",
		"item_potters_tools",
		"item_smiths_tools",
		"item_tinkers_tools",
		"item_weavers_tools",
		"item_woodcarvers_tools",
	])

	match background_resource.resource_id:
		"background_entertainer":
			return {
				"fixed_item_ids": ["item_disguise_kit", "item_clothes_fine"],
				"groups": [
					{
						"id": "background_entertainer_instrument",
						"title": "Choose your musical instrument",
						"variants": [
							_build_equipment_variant("musical_instrument", "Musical instrument", [], instrument_item_ids, 1),
						],
					},
				],
			}
		"background_folk_hero":
			return {
				"fixed_item_ids": ["item_backpack", "item_mess_kit", "item_clothes_common", "item_pouch"],
				"groups": [
					{
						"id": "background_folk_hero_tools",
						"title": "Choose your artisan's tools",
						"variants": [
							_build_equipment_variant("artisan_tools", "Artisan's tools", [], artisan_tool_item_ids, 1),
						],
					},
				],
			}
		"background_guild_artisan":
			return {
				"fixed_item_ids": ["item_clothes_traveler", "item_pouch"],
				"groups": [
					{
						"id": "background_guild_artisan_tools",
						"title": "Choose your artisan's tools",
						"variants": [
							_build_equipment_variant("artisan_tools", "Artisan's tools", [], artisan_tool_item_ids, 1),
						],
					},
				],
			}
		_:
			var item_ids: Array[String] = []
			for item_id in background_resource.starting_equipment_options:
				item_ids.append(str(item_id))
			return {
				"fixed_item_ids": item_ids,
				"groups": [],
			}


func _get_class_equipment_spec(class_resource: ClassResource) -> Dictionary:
	if class_resource == null:
		return {"fixed_item_ids": [], "groups": []}

	var simple_weapon_ids := _get_weapon_item_ids([ItemResource.WeaponType.SIMPLE_MELEE, ItemResource.WeaponType.SIMPLE_RANGED])
	var simple_melee_weapon_ids := _get_weapon_item_ids([ItemResource.WeaponType.SIMPLE_MELEE])
	var martial_weapon_ids := _get_weapon_item_ids([ItemResource.WeaponType.MARTIAL_MELEE, ItemResource.WeaponType.MARTIAL_RANGED])
	var martial_melee_weapon_ids := _get_weapon_item_ids([ItemResource.WeaponType.MARTIAL_MELEE])
	var instrument_item_ids: Array[String] = _filter_existing_item_ids(["item_drum", "item_flute", "item_lute", "item_lyre"])
	var arcane_focus_item_ids: Array[String] = _filter_existing_item_ids(["item_arcane_focus_crystal", "item_arcane_focus_orb"])

	match class_resource.resource_id:
		"class_barbarian":
			return {
				"fixed_item_ids": ["item_explorer_pack", "item_javelin", "item_javelin", "item_javelin", "item_javelin"],
				"groups": [
					{
						"id": "barbarian_primary_weapon",
						"title": "Choose your primary weapon",
						"variants": [
							_build_equipment_variant("greataxe", "Greataxe", ["item_greataxe"]),
							_build_equipment_variant("martial_melee_weapon", "Any martial melee weapon", [], martial_melee_weapon_ids, 1),
						],
					},
					{
						"id": "barbarian_secondary_weapon",
						"title": "Choose your secondary weapon",
						"variants": [
							_build_equipment_variant("two_handaxes", "Two handaxes", ["item_handaxe", "item_handaxe"]),
							_build_equipment_variant("simple_weapon", "Any simple weapon", [], simple_weapon_ids, 1),
						],
					},
				],
			}
		"class_bard":
			return {
				"fixed_item_ids": ["item_leather_armor", "item_dagger"],
				"groups": [
					{
						"id": "bard_weapon",
						"title": "Choose your weapon",
						"variants": [
							_build_equipment_variant("rapier", "Rapier", ["item_rapier"]),
							_build_equipment_variant("longsword", "Longsword", ["item_longsword"]),
							_build_equipment_variant("simple_weapon", "Any simple weapon", [], simple_weapon_ids, 1),
						],
					},
					{
						"id": "bard_pack",
						"title": "Choose your pack",
						"variants": [
							_build_equipment_variant("diplomat_pack", "Diplomat's Pack", ["item_diplomat_pack"]),
							_build_equipment_variant("entertainer_pack", "Entertainer's Pack", ["item_entertainer_pack"]),
						],
					},
					{
						"id": "bard_instrument",
						"title": "Choose your musical instrument",
						"variants": [
							_build_equipment_variant("musical_instrument", "Musical instrument", [], instrument_item_ids, 1),
						],
					},
				],
			}
		"class_cleric":
			return {
				"fixed_item_ids": ["item_shield", "item_holy_symbol_amulet"],
				"groups": [
					{
						"id": "cleric_weapon",
						"title": "Choose your weapon",
						"variants": [
							_build_equipment_variant("mace", "Mace", ["item_mace"]),
							_build_equipment_variant("warhammer", "Warhammer", ["item_warhammer"]),
						],
					},
					{
						"id": "cleric_armor",
						"title": "Choose your armor",
						"variants": [
							_build_equipment_variant("scale_mail", "Scale Mail", ["item_scale_mail"]),
							_build_equipment_variant("leather_armor", "Leather Armor", ["item_leather_armor"]),
							_build_equipment_variant("chain_mail", "Chain Mail", ["item_chain_mail"]),
						],
					},
					{
						"id": "cleric_secondary_weapon",
						"title": "Choose your secondary weapon",
						"variants": [
							_build_equipment_variant("crossbow", "Light Crossbow and 20 bolts", ["item_crossbow_light", "item_crossbow_bolts"]),
							_build_equipment_variant("simple_weapon", "Any simple weapon", [], simple_weapon_ids, 1),
						],
					},
					{
						"id": "cleric_pack",
						"title": "Choose your pack",
						"variants": [
							_build_equipment_variant("priest_pack", "Priest's Pack", ["item_priest_pack"]),
							_build_equipment_variant("explorer_pack", "Explorer's Pack", ["item_explorer_pack"]),
						],
					},
				],
			}
		"class_druid":
			return {
				"fixed_item_ids": ["item_leather_armor", "item_explorer_pack", "item_druidic_focus_sprig"],
				"groups": [
					{
						"id": "druid_primary_item",
						"title": "Choose your primary item",
						"variants": [
							_build_equipment_variant("shield", "Wooden Shield", ["item_shield"]),
							_build_equipment_variant("simple_weapon", "Any simple weapon", [], simple_weapon_ids, 1),
						],
					},
					{
						"id": "druid_secondary_weapon",
						"title": "Choose your secondary weapon",
						"variants": [
							_build_equipment_variant("scimitar", "Scimitar", ["item_scimitar"]),
							_build_equipment_variant("simple_melee_weapon", "Any simple melee weapon", [], simple_melee_weapon_ids, 1),
						],
					},
				],
			}
		"class_fighter":
			return {
				"fixed_item_ids": [],
				"groups": [
					{
						"id": "fighter_armor",
						"title": "Choose your armor package",
						"variants": [
							_build_equipment_variant("chain_mail", "Chain Mail", ["item_chain_mail"]),
							_build_equipment_variant("leather_and_longbow", "Leather armor, longbow, and 20 arrows", ["item_leather_armor", "item_longbow", "item_arrows"]),
						],
					},
					{
						"id": "fighter_primary_arms",
						"title": "Choose your primary arms",
						"variants": [
							_build_equipment_variant("martial_weapon_shield", "Martial weapon and shield", [], martial_weapon_ids, 1, ["item_shield"]),
							_build_equipment_variant("two_martial_weapons", "Two martial weapons", [], martial_weapon_ids, 2),
						],
					},
					{
						"id": "fighter_secondary_weapon",
						"title": "Choose your secondary weapon",
						"variants": [
							_build_equipment_variant("crossbow", "Light Crossbow and 20 bolts", ["item_crossbow_light", "item_crossbow_bolts"]),
							_build_equipment_variant("two_handaxes", "Two handaxes", ["item_handaxe", "item_handaxe"]),
						],
					},
					{
						"id": "fighter_pack",
						"title": "Choose your pack",
						"variants": [
							_build_equipment_variant("dungeoneer_pack", "Dungeoneer's Pack", ["item_dungeoneer_pack"]),
							_build_equipment_variant("explorer_pack", "Explorer's Pack", ["item_explorer_pack"]),
						],
					},
				],
			}
		"class_monk":
			return {
				"fixed_item_ids": ["item_dart", "item_dart", "item_dart", "item_dart", "item_dart", "item_dart", "item_dart", "item_dart", "item_dart", "item_dart"],
				"groups": [
					{
						"id": "monk_weapon",
						"title": "Choose your weapon",
						"variants": [
							_build_equipment_variant("shortsword", "Shortsword", ["item_shortsword"]),
							_build_equipment_variant("simple_weapon", "Any simple weapon", [], simple_weapon_ids, 1),
						],
					},
					{
						"id": "monk_pack",
						"title": "Choose your pack",
						"variants": [
							_build_equipment_variant("dungeoneer_pack", "Dungeoneer's Pack", ["item_dungeoneer_pack"]),
							_build_equipment_variant("explorer_pack", "Explorer's Pack", ["item_explorer_pack"]),
						],
					},
				],
			}
		"class_paladin":
			return {
				"fixed_item_ids": ["item_chain_mail", "item_holy_symbol_amulet"],
				"groups": [
					{
						"id": "paladin_primary_arms",
						"title": "Choose your primary arms",
						"variants": [
							_build_equipment_variant("martial_weapon_shield", "Martial weapon and shield", [], martial_weapon_ids, 1, ["item_shield"]),
							_build_equipment_variant("two_martial_weapons", "Two martial weapons", [], martial_weapon_ids, 2),
						],
					},
					{
						"id": "paladin_secondary_weapon",
						"title": "Choose your secondary weapon",
						"variants": [
							_build_equipment_variant("five_javelins", "Five javelins", ["item_javelin", "item_javelin", "item_javelin", "item_javelin", "item_javelin"]),
							_build_equipment_variant("simple_melee_weapon", "Any simple melee weapon", [], simple_melee_weapon_ids, 1),
						],
					},
					{
						"id": "paladin_pack",
						"title": "Choose your pack",
						"variants": [
							_build_equipment_variant("priest_pack", "Priest's Pack", ["item_priest_pack"]),
							_build_equipment_variant("explorer_pack", "Explorer's Pack", ["item_explorer_pack"]),
						],
					},
				],
			}
		"class_ranger":
			return {
				"fixed_item_ids": ["item_longbow", "item_arrows"],
				"groups": [
					{
						"id": "ranger_armor",
						"title": "Choose your armor",
						"variants": [
							_build_equipment_variant("scale_mail", "Scale Mail", ["item_scale_mail"]),
							_build_equipment_variant("leather_armor", "Leather Armor", ["item_leather_armor"]),
						],
					},
					{
						"id": "ranger_weapons",
						"title": "Choose your melee weapons",
						"variants": [
							_build_equipment_variant("two_shortswords", "Two shortswords", ["item_shortsword", "item_shortsword"]),
							_build_equipment_variant("two_simple_melee_weapons", "Two simple melee weapons", [], simple_melee_weapon_ids, 2),
						],
					},
					{
						"id": "ranger_pack",
						"title": "Choose your pack",
						"variants": [
							_build_equipment_variant("dungeoneer_pack", "Dungeoneer's Pack", ["item_dungeoneer_pack"]),
							_build_equipment_variant("explorer_pack", "Explorer's Pack", ["item_explorer_pack"]),
						],
					},
				],
			}
		"class_rogue":
			return {
				"fixed_item_ids": ["item_leather_armor", "item_dagger", "item_dagger", "item_thieves_tools"],
				"groups": [
					{
						"id": "rogue_weapon",
						"title": "Choose your weapon",
						"variants": [
							_build_equipment_variant("rapier", "Rapier", ["item_rapier"]),
							_build_equipment_variant("shortsword", "Shortsword", ["item_shortsword"]),
						],
					},
					{
						"id": "rogue_secondary_weapon",
						"title": "Choose your ranged option",
						"variants": [
							_build_equipment_variant("shortbow", "Shortbow and 20 arrows", ["item_shortbow", "item_arrows"]),
							_build_equipment_variant("shortsword", "Shortsword", ["item_shortsword"]),
						],
					},
					{
						"id": "rogue_pack",
						"title": "Choose your pack",
						"variants": [
							_build_equipment_variant("burglar_pack", "Burglar's Pack", ["item_burglar_pack"]),
							_build_equipment_variant("dungeoneer_pack", "Dungeoneer's Pack", ["item_dungeoneer_pack"]),
							_build_equipment_variant("explorer_pack", "Explorer's Pack", ["item_explorer_pack"]),
						],
					},
				],
			}
		"class_sorcerer":
			return {
				"fixed_item_ids": ["item_dagger", "item_dagger"],
				"groups": [
					{
						"id": "sorcerer_weapon",
						"title": "Choose your weapon",
						"variants": [
							_build_equipment_variant("crossbow", "Light Crossbow and 20 bolts", ["item_crossbow_light", "item_crossbow_bolts"]),
							_build_equipment_variant("simple_weapon", "Any simple weapon", [], simple_weapon_ids, 1),
						],
					},
					{
						"id": "sorcerer_focus",
						"title": "Choose your spellcasting gear",
						"variants": [
							_build_equipment_variant("component_pouch", "Component Pouch", ["item_component_pouch"]),
							_build_equipment_variant("arcane_focus", "Arcane focus", [], arcane_focus_item_ids, 1),
						],
					},
					{
						"id": "sorcerer_pack",
						"title": "Choose your pack",
						"variants": [
							_build_equipment_variant("dungeoneer_pack", "Dungeoneer's Pack", ["item_dungeoneer_pack"]),
							_build_equipment_variant("explorer_pack", "Explorer's Pack", ["item_explorer_pack"]),
						],
					},
				],
			}
		"class_warlock":
			return {
				"fixed_item_ids": ["item_leather_armor", "item_dagger", "item_dagger"],
				"groups": [
					{
						"id": "warlock_weapon",
						"title": "Choose your weapon",
						"variants": [
							_build_equipment_variant("crossbow", "Light Crossbow and 20 bolts", ["item_crossbow_light", "item_crossbow_bolts"]),
							_build_equipment_variant("simple_weapon", "Any simple weapon", [], simple_weapon_ids, 1),
						],
					},
					{
						"id": "warlock_focus",
						"title": "Choose your spellcasting gear",
						"variants": [
							_build_equipment_variant("component_pouch", "Component Pouch", ["item_component_pouch"]),
							_build_equipment_variant("arcane_focus", "Arcane focus", [], arcane_focus_item_ids, 1),
						],
					},
					{
						"id": "warlock_pack",
						"title": "Choose your pack",
						"variants": [
							_build_equipment_variant("scholar_pack", "Scholar's Pack", ["item_scholar_pack"]),
							_build_equipment_variant("dungeoneer_pack", "Dungeoneer's Pack", ["item_dungeoneer_pack"]),
						],
					},
				],
			}
		"class_wizard":
			return {
				"fixed_item_ids": ["item_spellbook"],
				"groups": [
					{
						"id": "wizard_weapon",
						"title": "Choose your weapon",
						"variants": [
							_build_equipment_variant("quarterstaff", "Quarterstaff", ["item_quarterstaff"]),
							_build_equipment_variant("dagger", "Dagger", ["item_dagger"]),
						],
					},
					{
						"id": "wizard_focus",
						"title": "Choose your spellcasting gear",
						"variants": [
							_build_equipment_variant("component_pouch", "Component Pouch", ["item_component_pouch"]),
							_build_equipment_variant("arcane_focus", "Arcane focus", [], arcane_focus_item_ids, 1),
						],
					},
					{
						"id": "wizard_pack",
						"title": "Choose your pack",
						"variants": [
							_build_equipment_variant("scholar_pack", "Scholar's Pack", ["item_scholar_pack"]),
							_build_equipment_variant("explorer_pack", "Explorer's Pack", ["item_explorer_pack"]),
						],
					},
				],
			}
		_:
			return {"fixed_item_ids": [], "groups": []}


func _get_equipment_choice_state(scope: String) -> Dictionary:
	if scope == "background":
		return selected_background_equipment_choice_state
	return selected_class_equipment_choice_state


func _set_equipment_group_state(scope: String, group_id: String, state: Dictionary) -> void:
	if scope == "background":
		selected_background_equipment_choice_state[group_id] = state
		return
	selected_class_equipment_choice_state[group_id] = state


func _erase_equipment_group_state(scope: String, group_id: String) -> void:
	if scope == "background":
		selected_background_equipment_choice_state.erase(group_id)
		return
	selected_class_equipment_choice_state.erase(group_id)


func _are_equipment_choice_groups_complete(groups: Array, choice_state: Dictionary) -> bool:
	for group in groups:
		var group_id := str(group.get("id", ""))
		var state: Dictionary = choice_state.get(group_id, {})
		var variant := _find_equipment_group_variant(group, str(state.get("variant_id", "")))
		if variant.is_empty():
			return false

		var selection_count := int(variant.get("selection_count", 0))
		if selection_count <= 0:
			continue

		var selected_item_ids: Array[String] = []
		for item_id in state.get("selected_item_ids", []):
			selected_item_ids.append(str(item_id))
		if selected_item_ids.size() < selection_count:
			return false
		for item_id in selected_item_ids:
			if item_id.is_empty():
				return false
	return true


func _load_equipment_choice_state(saved_state: Variant, target_state: Dictionary) -> void:
	if not saved_state is Dictionary:
		return

	for group_id in saved_state.keys():
		var raw_group_state = saved_state.get(group_id, {})
		if not raw_group_state is Dictionary:
			continue

		var group_state: Dictionary = raw_group_state
		var selected_item_ids: Array[String] = []
		for item_id in group_state.get("selected_item_ids", []):
			selected_item_ids.append(str(item_id))
		target_state[str(group_id)] = {
			"variant_id": str(group_state.get("variant_id", "")),
			"selected_item_ids": selected_item_ids,
		}


func _duplicate_equipment_choice_state(choice_state: Dictionary) -> Dictionary:
	var duplicated := {}
	for group_id in choice_state.keys():
		var group_state: Dictionary = choice_state.get(group_id, {})
		var selected_item_ids: Array[String] = []
		for item_id in group_state.get("selected_item_ids", []):
			selected_item_ids.append(str(item_id))
		duplicated[str(group_id)] = {
			"variant_id": str(group_state.get("variant_id", "")),
			"selected_item_ids": selected_item_ids,
		}
	return duplicated


func _get_weapon_item_ids(weapon_types: Array, exclude_ids: Array[String] = []) -> Array[String]:
	var item_ids: Array[String] = []
	var excluded := {}
	for item_id in exclude_ids:
		excluded[item_id] = true
	for item in selected_item_resources.values():
		var resource := item as ItemResource
		if resource == null:
			continue
		if resource.category != ItemResource.Category.WEAPON:
			continue
		if excluded.has(resource.resource_id):
			continue
		if weapon_types.has(resource.weapon_type):
			item_ids.append(resource.resource_id)
	return _sort_item_ids_by_display_name(item_ids)


func _filter_existing_item_ids(item_ids: Array[String]) -> Array[String]:
	var filtered: Array[String] = []
	for item_id in item_ids:
		if selected_item_resources.has(item_id):
			filtered.append(item_id)
	return filtered


func _sort_item_ids_by_display_name(item_ids: Array[String]) -> Array[String]:
	var sorted_ids := item_ids.duplicate()
	sorted_ids.sort_custom(func(a: String, b: String) -> bool:
		return _get_item_display_name(a) < _get_item_display_name(b)
	)
	return sorted_ids


func _get_item_display_name(item_id: String) -> String:
	var item := selected_item_resources.get(item_id) as ItemResource
	return item.display_name if item != null else item_id


func _get_item_display_names(item_ids: Array) -> Array[String]:
	var names: Array[String] = []
	for item_id in item_ids:
		names.append(_get_item_display_name(str(item_id)))
	return names


func _get_item_display_entries_for_ids(item_ids: Array[String]) -> Array[String]:
	var items: Array[ItemResource] = []
	for item_id in item_ids:
		var item := selected_item_resources.get(item_id) as ItemResource
		if item != null:
			items.append(item)
	return _get_inventory_display_entries_from_items(items)


func _get_inventory_display_entries_from_items(items: Array[ItemResource]) -> Array[String]:
	var entries: Array[String] = []
	var counts := {}
	var ordered_ids: Array[String] = []
	var names := {}
	for item in items:
		if item == null:
			continue
		var stack_data := _get_item_stack_display_data(item)
		var stack_key := str(stack_data["key"])
		if not counts.has(stack_key):
			counts[stack_key] = 0
			ordered_ids.append(stack_key)
			names[stack_key] = str(stack_data["name"])
		counts[stack_key] = int(counts.get(stack_key, 0)) + int(stack_data["quantity"])

	for stack_key in ordered_ids:
		var count := int(counts.get(stack_key, 0))
		var display_name := str(names.get(stack_key, stack_key))
		if count > 1:
			entries.append("%s x%d" % [display_name, count])
		else:
			entries.append(display_name)
	return entries


func _build_race_button(race: RaceResource, index: int) -> Button:
	var button := _create_card_button(MAIN_SELECTION_CARD_MIN_HEIGHT, MAIN_SELECTION_CARD_MIN_WIDTH)
	button.pressed.connect(_on_race_selected.bind(index))
	button.tooltip_text = _join_tooltip_lines([
		race.display_name,
		race.description,
		_format_race_summary(race),
	])

	var content_row := _create_card_row(button)
	content_row.add_child(_create_selection_preview(race.resource_id, MAIN_SELECTION_PREVIEW_SIZE, "races", race.display_name))

	var info_column := _create_info_column(content_row)
	info_column.add_child(_create_card_text_label(race.display_name, 18, 2))
	info_column.add_child(_create_card_text_label(race.description, 0, 3))
	info_column.add_child(_create_card_text_label(_format_race_summary(race), 0, 2))

	return button


func _build_class_button(class_resource: ClassResource, index: int) -> Button:
	var button := _create_card_button(MAIN_SELECTION_CARD_MIN_HEIGHT, MAIN_SELECTION_CARD_MIN_WIDTH)
	button.pressed.connect(_on_class_selected.bind(index))
	button.tooltip_text = _join_tooltip_lines([
		class_resource.display_name,
		"Hit Die: %s" % class_resource.hit_die,
		class_resource.description,
		_format_class_card_summary(class_resource),
	])

	var content_row := _create_card_row(button)
	content_row.add_child(_create_selection_preview(class_resource.resource_id, MAIN_SELECTION_PREVIEW_SIZE, "classes", class_resource.display_name))

	var info_column := _create_info_column(content_row)
	info_column.add_child(_create_card_text_label(class_resource.display_name, 18, 2))
	info_column.add_child(_create_card_text_label("Hit Die: %s" % class_resource.hit_die, 0, 1))
	info_column.add_child(_create_card_text_label(class_resource.description, 0, 3))
	info_column.add_child(_create_card_text_label(_format_class_card_summary(class_resource), 0, 2))

	return button


func _build_background_button(background: BackgroundResource, index: int) -> Button:
	var button := _create_card_button(MAIN_SELECTION_CARD_MIN_HEIGHT, MAIN_SELECTION_CARD_MIN_WIDTH)
	button.pressed.connect(_on_background_selected.bind(index))
	button.tooltip_text = _join_tooltip_lines([
		background.display_name,
		background.description,
	])

	var content_row := _create_card_row(button)
	content_row.add_child(_create_selection_preview(background.resource_id, MAIN_SELECTION_PREVIEW_SIZE, "backgrounds", background.display_name))

	var info_column := _create_info_column(content_row)
	info_column.add_child(_create_card_text_label(background.display_name, 17, 2))
	info_column.add_child(_create_card_text_label(background.description, 0, 4))

	return button


func _build_feat_button(feat: FeatResource, index: int) -> Button:
	var button := _create_card_button(FEAT_SELECTION_CARD_MIN_HEIGHT, MAIN_SELECTION_CARD_MIN_WIDTH)
	button.pressed.connect(_on_feat_inspect_requested.bind(index))
	button.tooltip_text = _join_tooltip_lines([
		feat.display_name,
		"Prerequisites: %s" % _format_feat_prerequisites(feat),
		feat.description,
		"Select to view feat details",
	])

	var info_column := _create_text_card_column(button)
	info_column.add_child(_create_card_text_label(feat.display_name, 18, 2))
	info_column.add_child(_create_card_text_label("Prerequisites: %s" % _format_feat_prerequisites(feat), 0, 2))
	info_column.add_child(_create_card_text_label(feat.description, 0, 3))

	return button


func _build_spell_button(spell: SpellResource, selected: bool, callback: Callable) -> Button:
	var button := _create_card_button(SPELL_SELECTION_CARD_MIN_HEIGHT, SPELL_SELECTION_CARD_MIN_WIDTH)
	button.toggle_mode = true
	button.button_pressed = selected
	button.pressed.connect(callback)
	button.tooltip_text = _join_tooltip_lines([
		spell.display_name,
		"%s | %s | %s" % [_format_spell_level_label(spell.spell_level), spell.school, spell.casting_time],
		spell.spell_text,
	])

	var content_row := _create_card_row(button)
	content_row.add_child(_create_selection_preview(spell.resource_id, SPELL_SELECTION_PREVIEW_SIZE, "spells", spell.display_name))

	var info_column := _create_info_column(content_row)
	info_column.add_child(_create_card_text_label(spell.display_name, 18, 2))
	info_column.add_child(_create_card_text_label("%s | %s | %s" % [_format_spell_level_label(spell.spell_level), spell.school, spell.casting_time], 0, 2))
	info_column.add_child(_create_card_text_label(spell.spell_text, 0, 4))

	return button


func _build_pack_button(item: ItemResource, index: int) -> Button:
	var button := _create_card_button(MAIN_SELECTION_CARD_MIN_HEIGHT)
	button.pressed.connect(_on_pack_selected.bind(index))
	button.tooltip_text = _join_tooltip_lines([
		item.display_name,
		item.description,
		"Includes %d items | %s gp" % [item.default_contents.size(), str(item.cost_gp)],
	])

	var content_row := _create_card_row(button)
	content_row.add_child(_create_selection_preview(item.resource_id, MAIN_SELECTION_PREVIEW_SIZE, "items", item.display_name))

	var info_column := _create_info_column(content_row)
	info_column.add_child(_create_card_text_label(item.display_name, 18, 2))
	info_column.add_child(_create_card_text_label(item.description, 0, 3))
	info_column.add_child(_create_card_text_label("Includes %d items | %s gp" % [item.default_contents.size(), str(item.cost_gp)], 0, 2))

	return button


func _rebuild_individual_items_list() -> void:
	for child in individual_items_list_container.get_children():
		child.queue_free()

	var search_text := item_search_line_edit.text.strip_edges().to_lower()
	var category_buckets := {
		"Weapons": [],
		"Armor": [],
		"Tools": [],
		"Other": [],
	}

	for item in available_individual_items:
		if item == null:
			continue
		if not _item_matches_search(item, search_text):
			continue

		match item.category:
			ItemResource.Category.WEAPON:
				category_buckets["Weapons"].append(item)
			ItemResource.Category.ARMOR:
				category_buckets["Armor"].append(item)
			ItemResource.Category.TOOL:
				category_buckets["Tools"].append(item)
			_:
				category_buckets["Other"].append(item)

	for category_name in ["Weapons", "Armor", "Tools", "Other"]:
		var items: Array = category_buckets[category_name]
		if items.is_empty():
			continue

		var header := Label.new()
		header.text = category_name
		header.add_theme_font_size_override("font_size", 18)
		individual_items_list_container.add_child(header)

		var section := VBoxContainer.new()
		section.add_theme_constant_override("separation", 10)
		individual_items_list_container.add_child(section)

		for item in items:
			section.add_child(_build_individual_item_button(item))


func _build_individual_item_button(item: ItemResource) -> Button:
	var button := _create_card_button(MAIN_SELECTION_CARD_MIN_HEIGHT)
	button.toggle_mode = true
	button.button_pressed = selected_individual_item_ids.has(item.resource_id)
	button.pressed.connect(_on_individual_item_toggled.bind(item.resource_id))
	button.tooltip_text = _join_tooltip_lines([
		item.display_name,
		item.description,
		_format_item_meta(item),
	])

	var content_row := _create_card_row(button)
	content_row.add_child(_create_selection_preview(item.resource_id, MAIN_SELECTION_PREVIEW_SIZE, "items", item.display_name))

	var info_column := _create_info_column(content_row)
	info_column.add_child(_create_card_text_label(item.display_name, 17, 2))
	info_column.add_child(_create_card_text_label(item.description, 0, 3))
	info_column.add_child(_create_card_text_label(_format_item_meta(item), 0, 2))

	return button


func _create_card_button(min_height: int, min_width: int = 0) -> Button:
	var button := Button.new()
	button.toggle_mode = true
	button.custom_minimum_size = Vector2(min_width, min_height)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.focus_mode = Control.FOCUS_NONE
	button.text = ""
	button.clip_contents = true
	return button


func _create_card_row(button: Button) -> HBoxContainer:
	var content_margin := MarginContainer.new()
	content_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content_margin.add_theme_constant_override("margin_left", 12)
	content_margin.add_theme_constant_override("margin_top", 12)
	content_margin.add_theme_constant_override("margin_right", 12)
	content_margin.add_theme_constant_override("margin_bottom", 12)
	button.add_child(content_margin)

	var content_row := HBoxContainer.new()
	content_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content_row.add_theme_constant_override("separation", 12)
	content_margin.add_child(content_row)
	return content_row


func _create_text_card_column(button: Button) -> VBoxContainer:
	var content_margin := MarginContainer.new()
	content_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content_margin.add_theme_constant_override("margin_left", 14)
	content_margin.add_theme_constant_override("margin_top", 12)
	content_margin.add_theme_constant_override("margin_right", 14)
	content_margin.add_theme_constant_override("margin_bottom", 12)
	button.add_child(content_margin)

	var content_column := VBoxContainer.new()
	content_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content_column.add_theme_constant_override("separation", 6)
	content_margin.add_child(content_column)
	return content_column


func _create_selection_preview(resource_id: String, preview_size: Vector2, portrait_group: String = "", display_name: String = "") -> Control:
	var preview_frame := PanelContainer.new()
	preview_frame.custom_minimum_size = preview_size + Vector2(16, 16)
	preview_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color(0.14, 0.16, 0.2, 0.95)
	frame_style.border_color = Color(0.32, 0.36, 0.43, 1.0)
	frame_style.border_width_left = 1
	frame_style.border_width_top = 1
	frame_style.border_width_right = 1
	frame_style.border_width_bottom = 1
	frame_style.corner_radius_top_left = 10
	frame_style.corner_radius_top_right = 10
	frame_style.corner_radius_bottom_right = 10
	frame_style.corner_radius_bottom_left = 10
	preview_frame.add_theme_stylebox_override("panel", frame_style)

	var preview_margin := MarginContainer.new()
	preview_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_margin.add_theme_constant_override("margin_left", 8)
	preview_margin.add_theme_constant_override("margin_top", 8)
	preview_margin.add_theme_constant_override("margin_right", 8)
	preview_margin.add_theme_constant_override("margin_bottom", 8)
	preview_frame.add_child(preview_margin)

	var preview_center := CenterContainer.new()
	preview_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_center.custom_minimum_size = preview_size
	preview_margin.add_child(preview_center)

	var preview_texture_rect := TextureRect.new()
	preview_texture_rect.custom_minimum_size = preview_size
	preview_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_texture_rect.texture = _get_selection_preview_texture(resource_id, preview_size, portrait_group, display_name)
	preview_center.add_child(preview_texture_rect)
	return preview_frame


func _get_selection_preview_texture(resource_id: String, preview_size: Vector2, portrait_group: String = "", display_name: String = "") -> Texture2D:
	var portrait_cache_key := "portrait::%s::%s::%s" % [portrait_group, resource_id, display_name]
	if selection_preview_texture_cache.has(portrait_cache_key):
		return selection_preview_texture_cache[portrait_cache_key] as Texture2D

	var portrait_texture := _load_portrait_texture(portrait_group, resource_id, display_name)
	if portrait_texture != null:
		selection_preview_texture_cache[portrait_cache_key] = portrait_texture
		return portrait_texture

	var cache_key := "fallback::%s_%dx%d" % [resource_id, int(preview_size.x), int(preview_size.y)]
	if selection_preview_texture_cache.has(cache_key):
		return selection_preview_texture_cache[cache_key] as Texture2D

	var image := Image.create(int(preview_size.x), int(preview_size.y), false, Image.FORMAT_RGBA8)
	image.fill(_get_resource_color(resource_id))
	var texture := ImageTexture.create_from_image(image)
	selection_preview_texture_cache[cache_key] = texture
	return texture


func _load_portrait_texture(portrait_group: String, resource_id: String, display_name: String) -> Texture2D:
	if portrait_group.is_empty():
		return null

	var portrait_lookup := _get_portrait_lookup(portrait_group)
	if portrait_lookup.is_empty():
		return null

	for candidate_name in _get_portrait_name_candidates(resource_id, display_name):
		var portrait_path := str(portrait_lookup.get(candidate_name, ""))
		if portrait_path.is_empty():
			continue
		var texture := _load_texture_from_image_path(portrait_path)
		if texture == null:
			texture = load(portrait_path) as Texture2D
		if texture != null:
			return texture

	return null


func _load_texture_from_image_path(resource_path: String) -> Texture2D:
	var absolute_path := ProjectSettings.globalize_path(resource_path)
	if not FileAccess.file_exists(absolute_path):
		return null

	var file_bytes := FileAccess.get_file_as_bytes(absolute_path)
	if file_bytes.is_empty():
		return null

	var image := Image.new()
	var load_error := _load_image_from_buffer(image, file_bytes)
	if load_error != OK or image.is_empty():
		return null

	return ImageTexture.create_from_image(image)


func _load_image_from_buffer(image: Image, file_bytes: PackedByteArray) -> Error:
	if _buffer_has_signature(file_bytes, PackedByteArray([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])):
		return image.load_png_from_buffer(file_bytes)
	if _buffer_has_signature(file_bytes, PackedByteArray([0xFF, 0xD8, 0xFF])):
		return image.load_jpg_from_buffer(file_bytes)
	if _buffer_has_signature(file_bytes, PackedByteArray([0x52, 0x49, 0x46, 0x46])) and _buffer_has_signature_at(file_bytes, PackedByteArray([0x57, 0x45, 0x42, 0x50]), 8):
		return image.load_webp_from_buffer(file_bytes)
	return ERR_FILE_UNRECOGNIZED


func _buffer_has_signature(buffer: PackedByteArray, signature: PackedByteArray) -> bool:
	return _buffer_has_signature_at(buffer, signature, 0)


func _buffer_has_signature_at(buffer: PackedByteArray, signature: PackedByteArray, offset: int) -> bool:
	if buffer.size() < offset + signature.size():
		return false
	for index in range(signature.size()):
		if buffer[offset + index] != signature[index]:
			return false
	return true


func _get_portrait_lookup(portrait_group: String) -> Dictionary:
	if portrait_file_cache.has(portrait_group):
		return portrait_file_cache[portrait_group] as Dictionary

	var portrait_dir := "%s/%s" % [PORTRAIT_ROOT_PATH, portrait_group]
	var lookup := {}
	var priorities := {}
	if DirAccess.dir_exists_absolute(portrait_dir):
		for file_name in DirAccess.get_files_at(portrait_dir):
			var extension := file_name.get_extension().to_lower()
			if not extension.is_empty() and not SUPPORTED_PORTRAIT_EXTENSIONS.has(extension):
				continue
			var base_name := file_name.get_basename().to_lower()
			if extension.is_empty():
				base_name = file_name.to_lower()
			var priority := int(PORTRAIT_EXTENSION_PRIORITY.get(extension, 100))
			var existing_priority := int(priorities.get(base_name, 999))
			if priority >= existing_priority:
				continue
			lookup[base_name] = "%s/%s" % [portrait_dir, file_name]
			priorities[base_name] = priority

	portrait_file_cache[portrait_group] = lookup
	return lookup


func _get_portrait_name_candidates(resource_id: String, display_name: String) -> Array[String]:
	var candidates: Array[String] = []
	var seen := {}

	var add_candidate := func(candidate: String) -> void:
		var cleaned := candidate.strip_edges().to_lower()
		if cleaned.is_empty() or seen.has(cleaned):
			return
		seen[cleaned] = true
		candidates.append(cleaned)

	add_candidate.call(resource_id)
	add_candidate.call(_normalize_portrait_name(display_name))

	var id_parts := resource_id.to_lower().split("_", false)
	var normalized_display_name := _normalize_portrait_name(display_name)
	if id_parts.size() >= 3:
		var prefix := id_parts[0]
		var suffix_parts := id_parts.slice(1)
		add_candidate.call("%s_%s" % [prefix, "_".join(suffix_parts)])
		if suffix_parts.size() == 2:
			add_candidate.call("%s_%s_%s" % [prefix, suffix_parts[1], suffix_parts[0]])
		if suffix_parts.size() > 2:
			var head := suffix_parts[0]
			var tail := suffix_parts.slice(1)
			add_candidate.call("%s_%s_%s" % [prefix, "_".join(tail), head])

	if not normalized_display_name.is_empty() and not id_parts.is_empty():
		add_candidate.call("%s_%s" % [id_parts[0], normalized_display_name])

	var display_parts := normalized_display_name.split("_", false)
	if display_parts.size() >= 2:
		add_candidate.call("%s_%s" % [id_parts[0] if not id_parts.is_empty() else "portrait", "_".join(display_parts)])
		if display_parts.size() == 2 and not id_parts.is_empty():
			add_candidate.call("%s_%s_%s" % [id_parts[0], display_parts[1], display_parts[0]])

	return candidates


func _normalize_portrait_name(value: String) -> String:
	var normalized := value.to_lower().strip_edges()
	normalized = normalized.replace("-", "_")
	normalized = normalized.replace(" ", "_")
	while normalized.contains("__"):
		normalized = normalized.replace("__", "_")
	return normalized.strip_edges()


func _create_info_column(parent: Node) -> VBoxContainer:
	var info_column := VBoxContainer.new()
	info_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_column.add_theme_constant_override("separation", 6)
	parent.add_child(info_column)
	return info_column


func _create_card_text_label(text: String, font_size: int = 0, max_lines: int = 0) -> Label:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if font_size > 0:
		label.add_theme_font_size_override("font_size", font_size)
	if max_lines > 0:
		label.max_lines_visible = max_lines
		label.tooltip_text = text
	return label


func _join_tooltip_lines(lines: Array[String]) -> String:
	var filtered: Array[String] = []
	for line in lines:
		var cleaned := line.strip_edges()
		if cleaned.is_empty():
			continue
		filtered.append(cleaned)
	return "\n".join(filtered)


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
	var summary_mode := current_step == 8
	left_sidebar.visible = not summary_mode
	right_preview_panel.visible = not summary_mode
	race_step_container.visible = current_step == 0
	class_background_step_container.visible = current_step == 1 or current_step == 2
	skills_step_container.visible = current_step == 3
	abilities_step_container.visible = current_step == 4
	feats_step_container.visible = current_step == 5
	spells_step_container.visible = current_step == 6
	equipment_step_container.visible = current_step == 7
	summary_step_container.visible = current_step == 8
	class_selection_scroll.visible = current_step == 1
	background_section.visible = current_step == 2
	previous_button.visible = current_step > 0 and current_step <= 8
	next_button.visible = current_step >= 0 and current_step <= 7
	create_character_button.visible = current_step == 8

	match current_step:
		0:
			current_step_content_label.text = "Race Selection"
		1:
			current_step_content_label.text = "Class Selection"
		2:
			current_step_content_label.text = "Background Selection"
		3:
			current_step_content_label.text = "Skills Selection"
		4:
			current_step_content_label.text = "Ability Scores"
		5:
			current_step_content_label.text = "Feats Selection"
		6:
			current_step_content_label.text = _get_spell_phase_title()
		7:
			current_step_content_label.text = "Equipment Selection"
		8:
			current_step_content_label.text = "Summary & Finalization"
		_:
			current_step_content_label.text = "Current Step Content"

	_schedule_selection_grid_layout_refresh()


func _update_selection_buttons() -> void:
	_update_race_buttons()
	_update_class_buttons()
	_update_background_buttons()
	_update_feat_buttons()
	_update_pack_buttons()


func _schedule_selection_grid_layout_refresh() -> void:
	call_deferred("_update_selection_grid_layout")
	call_deferred("_update_selection_grid_layout_next_frame")


func _update_selection_grid_layout() -> void:
	_update_grid_columns(race_list_container, MAIN_SELECTION_CARD_MIN_WIDTH, GRID_SPACING_MAIN, GRID_MAX_COLUMNS_MAIN)
	_update_grid_columns(class_list_container, MAIN_SELECTION_CARD_MIN_WIDTH, GRID_SPACING_MAIN, GRID_MAX_COLUMNS_MAIN)
	_update_grid_columns(background_list_container, MAIN_SELECTION_CARD_MIN_WIDTH, GRID_SPACING_MAIN, GRID_MAX_COLUMNS_MAIN)
	_update_grid_columns(feat_list_container, MAIN_SELECTION_CARD_MIN_WIDTH, GRID_SPACING_MAIN, GRID_MAX_COLUMNS_MAIN)
	_update_grid_columns(class_cantrips_list_container, SPELL_SELECTION_CARD_MIN_WIDTH, GRID_SPACING_SPELL, GRID_MAX_COLUMNS_SPELL)
	_update_grid_columns(class_level_one_list_container, SPELL_SELECTION_CARD_MIN_WIDTH, GRID_SPACING_SPELL, GRID_MAX_COLUMNS_SPELL)
	_update_grid_columns(feat_cantrips_list_container, SPELL_SELECTION_CARD_MIN_WIDTH, GRID_SPACING_SPELL, GRID_MAX_COLUMNS_SPELL)
	_update_grid_columns(feat_level_one_list_container, SPELL_SELECTION_CARD_MIN_WIDTH, GRID_SPACING_SPELL, GRID_MAX_COLUMNS_SPELL)


func _update_selection_grid_layout_next_frame() -> void:
	await get_tree().process_frame
	_update_selection_grid_layout()


func _update_grid_columns(grid: GridContainer, target_card_width: int, spacing: int, max_columns: int) -> void:
	if grid == null:
		return

	var available_width := _get_grid_available_width(grid)
	if available_width <= 0.0:
		grid.columns = 1
		return

	var calculated_columns := int(floor((available_width + spacing) / float(target_card_width + spacing)))
	grid.columns = clampi(calculated_columns, 1, max_columns)


func _get_grid_available_width(grid: GridContainer) -> float:
	var current: Node = grid.get_parent()
	while current != null:
		var control := current as Control
		if control != null and control.visible and control.size.x > 0.0:
			return control.size.x
		current = current.get_parent()
	return 0.0


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


func _update_pack_buttons() -> void:
	for index in range(pack_buttons.size()):
		var button := pack_buttons[index] as Button
		if button == null:
			continue
		var pack := available_pack_items[index] as ItemResource
		button.button_pressed = _is_selected_pack(pack)


func _update_next_button_state() -> void:
	match current_step:
		0:
			next_button.disabled = selected_race == null
		1:
			next_button.disabled = selected_class == null
		2:
			next_button.disabled = not _can_advance_from_background_step()
		3:
			next_button.disabled = not _can_advance_from_skills_step()
		4:
			next_button.disabled = _calculate_point_buy_total() != 27
		5:
			next_button.disabled = not _can_advance_from_feats_step()
		6:
			next_button.disabled = not _can_advance_from_spells_step()
		7:
			next_button.disabled = not _can_advance_from_equipment_step()
		_:
			next_button.disabled = true

	create_character_button.disabled = not _can_finalize_character()


func _refresh_skills_ui() -> void:
	_sanitize_skill_selection_state()
	_rebuild_automatic_skills_list()
	_rebuild_choose_skills_list()
	_update_skills_status()
	_sync_skills_to_character()


func _sanitize_skill_selection_state() -> void:
	_filter_selected_ids(selected_class_skill_ids, _collect_string_id_set(_get_available_class_skill_choice_ids()))
	_trim_selected_string_ids(selected_class_skill_ids, _get_required_class_skill_choice_count())


func _rebuild_automatic_skills_list() -> void:
	_clear_container_children(automatic_skills_list_container)

	var source_map := _get_automatic_skill_source_map()
	var skill_ids := _get_sorted_skill_ids_from_source_map(source_map)
	if skill_ids.is_empty():
		_add_empty_state_label(automatic_skills_list_container, "No automatic skill proficiencies granted yet.")
		return

	for skill_id in skill_ids:
		var skill_label := Label.new()
		skill_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		skill_label.text = "%s (%s)" % [_get_skill_display_name(skill_id), ", ".join(_get_skill_source_labels(source_map.get(skill_id, [])))]
		automatic_skills_list_container.add_child(skill_label)


func _rebuild_choose_skills_list() -> void:
	_clear_container_children(choose_skills_list_container)

	var required_count := _get_required_class_skill_choice_count()
	var available_choice_ids := _get_available_class_skill_choice_ids()
	choose_skills_panel.visible = selected_class != null and required_count > 0
	if not choose_skills_panel.visible:
		return

	if available_choice_ids.is_empty():
		_add_empty_state_label(choose_skills_list_container, "No remaining skills are available to choose from.")
		return

	for skill_id in available_choice_ids:
		var skill := skill_resource_cache.get(skill_id) as SkillResource
		if skill == null:
			continue
		choose_skills_list_container.add_child(_build_skill_choice_button(skill))


func _build_skill_choice_button(skill: SkillResource) -> Button:
	var button := _create_card_button(MAIN_SELECTION_CARD_MIN_HEIGHT)
	button.toggle_mode = true
	button.button_pressed = selected_class_skill_ids.has(skill.resource_id)
	button.pressed.connect(_on_class_skill_toggled.bind(skill.resource_id))
	button.tooltip_text = _join_tooltip_lines([
		skill.display_name,
		"Ability: %s" % ABILITY_LABELS.get(skill.ability_key, skill.ability_key.to_upper()),
		skill.description,
	])

	var content_row := _create_card_row(button)
	content_row.add_child(_create_selection_preview(skill.resource_id, MAIN_SELECTION_PREVIEW_SIZE, "skills", skill.display_name))

	var info_column := _create_info_column(content_row)
	info_column.add_child(_create_card_text_label(skill.display_name, 17, 2))
	info_column.add_child(_create_card_text_label("Ability: %s" % ABILITY_LABELS.get(skill.ability_key, skill.ability_key.to_upper()), 0, 1))

	if not skill.description.strip_edges().is_empty():
		info_column.add_child(_create_card_text_label(skill.description, 0, 2))

	return button


func _update_skills_status() -> void:
	if selected_class == null or selected_background == null:
		skills_status_label.text = "Select a class and background before choosing skills."
		_set_label_color(skills_status_label, Color(0.85, 0.65, 0.2))
		return

	var required_count := _get_required_class_skill_choice_count()
	if required_count <= 0:
		skills_status_label.text = "No class skill choices are required for this character."
		_set_label_color(skills_status_label, Color(0.7, 0.7, 0.7))
		return

	var selected_count := selected_class_skill_ids.size()
	if selected_count == required_count:
		skills_status_label.text = "Class skill choices complete: %d / %d selected." % [selected_count, required_count]
		_set_label_color(skills_status_label, Color(0.2, 0.7, 0.3))
	else:
		skills_status_label.text = "Select %d class skill(s): %d / %d chosen." % [required_count, selected_count, required_count]
		_set_label_color(skills_status_label, Color(0.85, 0.65, 0.2))


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
	magic_initiate_panel.visible = _requires_magic_initiate_spell_selection()
	_sync_variant_human_selector_values()
	_populate_magic_initiate_spell_list_option()
	_update_magic_initiate_status()
	_update_variant_human_status()
	_update_feat_status()


func _refresh_spells_ui() -> void:
	_sanitize_spell_selection_state()
	_normalize_spell_phase()

	var has_class_spellcasting := _has_class_spellcasting()
	var has_bonus_spell_selection := _has_bonus_spell_selection_requirements()
	spell_picker_panel.visible = has_class_spellcasting or has_bonus_spell_selection
	spell_detail_panel.visible = false
	class_spells_section.visible = false
	feat_spells_section.visible = false
	no_spells_required_label.visible = not has_class_spellcasting and not has_bonus_spell_selection

	_rebuild_spell_phase_rail()
	_update_spell_picker_summary()
	_rebuild_current_spell_list()
	_update_spell_status()
	_sync_spells_to_character()


func _rebuild_spell_phase_rail() -> void:
	_clear_container_children(spell_phase_rail)

	for phase in _get_spell_phases():
		var button := Button.new()
		button.toggle_mode = true
		button.button_pressed = phase == current_spell_phase
		button.text = _get_spell_phase_short_title(phase)
		button.tooltip_text = _get_spell_phase_status_text(phase)
		button.pressed.connect(_on_spell_phase_selected.bind(phase))
		spell_phase_rail.add_child(button)


func _update_spell_picker_summary() -> void:
	spell_phase_title_label.text = _get_spell_phase_title()

	var selection_limit := _get_current_spell_selection_limit()
	var selected_ids := _get_current_spell_selected_ids()
	spell_selection_summary_label.text = "Selected %d / %d" % [selected_ids.size(), selection_limit]

	_clear_container_children(selected_spell_chips_container)
	if selected_ids.is_empty():
		var empty_label := Label.new()
		empty_label.add_theme_font_size_override("font_size", 12)
		empty_label.text = "No spells selected in this phase yet."
		selected_spell_chips_container.add_child(empty_label)
		return

	for spell_id in _get_sorted_selected_spell_ids(selected_ids):
		var chip_button := Button.new()
		chip_button.text = "%s x" % _get_spell_display_name(spell_id)
		chip_button.custom_minimum_size = Vector2(0, 24)
		chip_button.add_theme_font_size_override("font_size", 11)
		chip_button.tooltip_text = "Remove %s from this phase" % _get_spell_display_name(spell_id)
		chip_button.pressed.connect(_on_selected_spell_chip_pressed.bind(spell_id))
		selected_spell_chips_container.add_child(chip_button)


func _rebuild_current_spell_list() -> void:
	_clear_container_children(spell_list_container)

	var search_text := spell_search_line_edit.text.strip_edges().to_lower()
	var spell_options := _get_filtered_current_spell_options(search_text)
	if spell_options.is_empty():
		_add_empty_state_label(spell_list_container, "No spells match the current phase and search.")
		return

	var source := _get_spell_source_for_phase(current_spell_phase)
	for spell in spell_options:
		spell_list_container.add_child(_build_spell_list_row(spell, _get_current_spell_selected_ids().has(spell.resource_id), source))


func _build_spell_list_row(spell: SpellResource, selected: bool, source: String) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14, 0.16, 0.2, 0.92) if not selected else Color(0.18, 0.24, 0.19, 0.96)
	style.border_color = Color(0.3, 0.34, 0.4, 1.0)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var content_row := HBoxContainer.new()
	content_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_row.add_theme_constant_override("separation", 10)
	margin.add_child(content_row)

	var info_column := VBoxContainer.new()
	info_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_column.add_theme_constant_override("separation", 4)
	content_row.add_child(info_column)

	var top_row := HBoxContainer.new()
	top_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_theme_constant_override("separation", 8)
	info_column.add_child(top_row)

	var select_toggle := CheckBox.new()
	select_toggle.text = ""
	select_toggle.button_pressed = selected
	select_toggle.custom_minimum_size = Vector2(22, 22)
	select_toggle.tooltip_text = "Select or remove %s" % spell.display_name
	select_toggle.pressed.connect(_on_spell_row_select_pressed.bind(spell.resource_id, spell.spell_level, source))
	top_row.add_child(select_toggle)

	var title_label := _create_card_text_label(spell.display_name, 17, 1)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(title_label)

	var details_button := Button.new()
	details_button.text = "?"
	details_button.custom_minimum_size = Vector2(28, 28)
	details_button.tooltip_text = "View spell details"
	details_button.pressed.connect(_on_spell_details_requested.bind(spell.resource_id))
	top_row.add_child(details_button)

	info_column.add_child(_create_card_text_label(_format_spell_row_meta(spell), 0, 2))

	return panel


func _on_spell_phase_selected(phase: String) -> void:
	current_spell_phase = phase
	_refresh_spells_ui()
	_update_next_button_state()


func _on_spell_search_text_changed(_new_text: String) -> void:
	_rebuild_current_spell_list()


func _on_spell_row_select_pressed(resource_id: String, spell_level: int, source: String) -> void:
	if source == "class":
		if spell_level == 0:
			_toggle_spell_selection(selected_class_cantrip_ids, resource_id, _get_required_class_cantrip_count())
		else:
			_toggle_spell_selection(selected_class_level_one_spell_ids, resource_id, _get_required_class_level_one_spell_count())
	else:
		if spell_level == 0:
			_toggle_spell_selection(selected_feat_cantrip_ids, resource_id, 2)
		else:
			_toggle_spell_selection(selected_feat_level_one_spell_ids, resource_id, 1)

	_refresh_spells_ui()
	_update_next_button_state()
	_refresh_preview()


func _on_spell_details_requested(resource_id: String) -> void:
	inspected_spell = spell_resource_cache.get(resource_id) as SpellResource
	_show_spell_details_popup(inspected_spell)


func _on_selected_spell_chip_pressed(resource_id: String) -> void:
	_on_spell_row_select_pressed(resource_id, _get_current_spell_level(), _get_spell_source_for_phase(current_spell_phase))


func _get_filtered_current_spell_options(search_text: String) -> Array:
	var filtered: Array = []
	for spell in _get_current_spell_options():
		if search_text.is_empty() or _spell_matches_search(spell, search_text):
			filtered.append(spell)
	return filtered


func _get_current_spell_options() -> Array:
	match current_spell_phase:
		SPELL_PHASE_CLASS_CANTRIPS:
			return _get_class_spells_by_level(0)
		SPELL_PHASE_CLASS_LEVEL_ONE:
			return _get_class_spells_by_level(1)
		SPELL_PHASE_BONUS_CANTRIPS:
			return _get_magic_initiate_spells_by_level(0)
		SPELL_PHASE_BONUS_LEVEL_ONE:
			return _get_magic_initiate_spells_by_level(1)
		_:
			return []


func _get_current_spell_selected_ids() -> Dictionary:
	match current_spell_phase:
		SPELL_PHASE_CLASS_CANTRIPS:
			return selected_class_cantrip_ids
		SPELL_PHASE_CLASS_LEVEL_ONE:
			return selected_class_level_one_spell_ids
		SPELL_PHASE_BONUS_CANTRIPS:
			return selected_feat_cantrip_ids
		SPELL_PHASE_BONUS_LEVEL_ONE:
			return selected_feat_level_one_spell_ids
		_:
			return {}


func _get_current_spell_selection_limit() -> int:
	match current_spell_phase:
		SPELL_PHASE_CLASS_CANTRIPS:
			return _get_required_class_cantrip_count()
		SPELL_PHASE_CLASS_LEVEL_ONE:
			return _get_required_class_level_one_spell_count()
		SPELL_PHASE_BONUS_CANTRIPS:
			return 2
		SPELL_PHASE_BONUS_LEVEL_ONE:
			return 1
		_:
			return 0


func _get_current_spell_level() -> int:
	if current_spell_phase == SPELL_PHASE_CLASS_LEVEL_ONE or current_spell_phase == SPELL_PHASE_BONUS_LEVEL_ONE:
		return 1
	return 0


func _get_spell_source_for_phase(phase: String) -> String:
	return "feat" if _is_bonus_spell_phase(phase) else "class"


func _get_spell_phase_short_title(phase: String) -> String:
	match phase:
		SPELL_PHASE_CLASS_CANTRIPS:
			return "Cantrips"
		SPELL_PHASE_CLASS_LEVEL_ONE:
			return "Level 1"
		SPELL_PHASE_BONUS_CANTRIPS:
			return "Bonus Cantrips"
		SPELL_PHASE_BONUS_LEVEL_ONE:
			return "Bonus Level 1"
		_:
			return "Spells"


func _get_spell_phase_status_text(phase: String) -> String:
	var selected_ids := _get_spell_selected_ids_for_phase(phase)
	var limit := _get_spell_selection_limit_for_phase(phase)
	return "%s %d / %d." % [_get_current_spell_phase_status_text_for_phase(phase), selected_ids.size(), limit]


func _get_current_spell_phase_status_text_for_phase(phase: String) -> String:
	match phase:
		SPELL_PHASE_CLASS_CANTRIPS:
			return "Class cantrips"
		SPELL_PHASE_CLASS_LEVEL_ONE:
			return "Class level 1"
		SPELL_PHASE_BONUS_CANTRIPS:
			return "Bonus cantrips"
		SPELL_PHASE_BONUS_LEVEL_ONE:
			return "Bonus level 1"
		_:
			return "Spells"


func _get_spell_selected_ids_for_phase(phase: String) -> Dictionary:
	match phase:
		SPELL_PHASE_CLASS_CANTRIPS:
			return selected_class_cantrip_ids
		SPELL_PHASE_CLASS_LEVEL_ONE:
			return selected_class_level_one_spell_ids
		SPELL_PHASE_BONUS_CANTRIPS:
			return selected_feat_cantrip_ids
		SPELL_PHASE_BONUS_LEVEL_ONE:
			return selected_feat_level_one_spell_ids
		_:
			return {}


func _get_spell_selection_limit_for_phase(phase: String) -> int:
	match phase:
		SPELL_PHASE_CLASS_CANTRIPS:
			return _get_required_class_cantrip_count()
		SPELL_PHASE_CLASS_LEVEL_ONE:
			return _get_required_class_level_one_spell_count()
		SPELL_PHASE_BONUS_CANTRIPS:
			return 2
		SPELL_PHASE_BONUS_LEVEL_ONE:
			return 1
		_:
			return 0


func _spell_matches_search(spell: SpellResource, search_text: String) -> bool:
	var haystack := "%s %s %s %s %s %s %s" % [
		spell.display_name,
		spell.school,
		spell.casting_time,
		spell.spell_range,
		spell.components,
		spell.duration,
		spell.spell_text,
	]
	return haystack.to_lower().contains(search_text)


func _format_spell_row_meta(spell: SpellResource) -> String:
	return "%s | %s | %s" % [_format_spell_level_label(spell.spell_level), spell.school, spell.casting_time]


func _format_spell_detail_text(spell: SpellResource) -> String:
	var sections: Array[String] = []
	sections.append("[b]Rules Text[/b]\n%s" % spell.spell_text)
	if not spell.higher_levels.strip_edges().is_empty():
		sections.append("[b]At Higher Levels[/b]\n%s" % spell.higher_levels)
	return "\n\n".join(sections)


func _get_spell_display_name(resource_id: String) -> String:
	var spell := spell_resource_cache.get(resource_id) as SpellResource
	return spell.display_name if spell != null else resource_id


func _show_spell_details_popup(spell: SpellResource) -> void:
	if spell == null:
		return

	spell_details_title_label.text = spell.display_name
	spell_details_meta_label.text = "%s\nRange %s | Components %s | Duration %s" % [
		_format_spell_row_meta(spell),
		spell.spell_range,
		spell.components,
		spell.duration,
	]
	spell_details_rules_label.text = _format_spell_detail_text(spell)
	spell_details_dialog.popup_centered_ratio(0.52)


func _rebuild_class_spell_lists() -> void:
	_clear_container_children(class_cantrips_list_container)
	_clear_container_children(class_level_one_list_container)

	var cantrip_limit := _get_required_class_cantrip_count()
	var level_one_limit := _get_required_class_level_one_spell_count()
	class_cantrips_counter_label.text = "Selected %d / %d" % [selected_class_cantrip_ids.size(), cantrip_limit]
	class_level_one_counter_label.text = "Selected %d / %d" % [selected_class_level_one_spell_ids.size(), level_one_limit]

	var cantrip_options := _get_class_spells_by_level(0)
	if cantrip_options.is_empty():
		_add_empty_state_label(class_cantrips_list_container, "No class cantrips available.")
	else:
		for spell in cantrip_options:
			class_cantrips_list_container.add_child(_build_spell_button(spell, selected_class_cantrip_ids.has(spell.resource_id), _on_class_spell_toggled.bind(spell.resource_id, 0)))

	var level_one_options := _get_class_spells_by_level(1)
	if level_one_options.is_empty():
		_add_empty_state_label(class_level_one_list_container, "No class level 1 spells available.")
	else:
		for spell in level_one_options:
			class_level_one_list_container.add_child(_build_spell_button(spell, selected_class_level_one_spell_ids.has(spell.resource_id), _on_class_spell_toggled.bind(spell.resource_id, 1)))


func _rebuild_feat_spell_lists() -> void:
	_clear_container_children(feat_cantrips_list_container)
	_clear_container_children(feat_level_one_list_container)

	if not _has_bonus_spell_selection_requirements():
		feat_spells_description_label.text = "No bonus spell selections are currently required."
		feat_cantrips_counter_label.text = "Selected 0 / 0"
		feat_level_one_counter_label.text = "Selected 0 / 0"
		return

	feat_spells_description_label.text = "Complete any extra spell choices granted by feats or other character options."
	feat_cantrips_counter_label.text = "Selected %d / 2" % selected_feat_cantrip_ids.size()
	feat_level_one_counter_label.text = "Selected %d / 1" % selected_feat_level_one_spell_ids.size()

	var cantrip_options := _get_magic_initiate_spells_by_level(0)
	if cantrip_options.is_empty():
		_add_empty_state_label(feat_cantrips_list_container, "No bonus cantrips are available for the current feat configuration.")
	else:
		for spell in cantrip_options:
			feat_cantrips_list_container.add_child(_build_spell_button(spell, selected_feat_cantrip_ids.has(spell.resource_id), _on_feat_spell_toggled.bind(spell.resource_id, 0)))

	var level_one_options := _get_magic_initiate_spells_by_level(1)
	if level_one_options.is_empty():
		_add_empty_state_label(feat_level_one_list_container, "No bonus level 1 spells are available for the current feat configuration.")
	else:
		for spell in level_one_options:
			feat_level_one_list_container.add_child(_build_spell_button(spell, selected_feat_level_one_spell_ids.has(spell.resource_id), _on_feat_spell_toggled.bind(spell.resource_id, 1)))


func _update_spell_status() -> void:
	if not _has_spell_selection_requirements():
		spell_status_label.text = "No spell selection required for this build."
		_set_label_color(spell_status_label, Color(0.7, 0.7, 0.7))
		return

	if _is_current_spell_phase_complete():
		if _is_last_spell_phase():
			spell_status_label.text = "Spell selection complete."
		else:
			spell_status_label.text = "Phase complete. Continue."
		_set_label_color(spell_status_label, Color(0.2, 0.7, 0.3))
	else:
		spell_status_label.text = _get_current_spell_phase_status_text()
		_set_label_color(spell_status_label, Color(0.85, 0.65, 0.2))


func _clear_container_children(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()


func _add_empty_state_label(container: Node, text: String) -> void:
	if container is GridContainer:
		(container as GridContainer).columns = 1

	var label := Label.new()
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(320, 0)
	label.text = text
	container.add_child(label)


func _refresh_equipment_ui() -> void:
	use_default_gold_checkbox.visible = selected_class != null and selected_background != null
	use_default_gold_checkbox.button_pressed = use_default_starting_gold
	_refresh_allowed_equipment_options()
	_sync_equipment_to_character()
	_rebuild_equipment_summary_list()
	_update_equipment_status()


func _refresh_summary_ui() -> void:
	var character := CharacterCreationManager.current_character
	var character_name := character.character_name if character != null else ""
	if character_name_input.text != character_name:
		character_name_input.text = character_name
	summary_preview.text = _format_summary_preview(character)


func _refresh_preview() -> void:
	var character := CharacterCreationManager.current_character
	var race := selected_race

	character_name_preview.text = "[b]Character Name:[/b] %s" % _get_character_name(character)
	race_preview.text = "[b]Race:[/b] %s" % _format_race_preview(race)
	class_preview.text = "[b]Class:[/b] %s" % _format_class_preview(character)
	background_preview.text = "[b]Background:[/b] %s" % _format_background_preview(character)
	hp_preview.text = "[b]HP:[/b] %s" % _format_hp_preview(character, race)
	spellcasting_preview.text = "[b]Spellcasting:[/b] %s" % _format_spellcasting_preview(character, race)
	skills_preview.text = "[b]Skills:[/b]%s" % _format_skills_preview(character)

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

	known_spells_preview.text = _format_known_spells_preview(character)
	_refresh_inventory_gold_preview(character)
	_refresh_summary_ui()


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
	_refresh_skills_ui()
	_refresh_feat_ui()
	_refresh_spells_ui()
	_refresh_ability_scores_ui()
	_update_next_button_state()
	_refresh_preview()


func _on_class_selected(index: int) -> void:
	if index < 0 or index >= available_classes.size():
		return

	selected_class = available_classes[index] as ClassResource
	_ensure_current_character()
	CharacterCreationManager.current_character.class_resource = selected_class
	_refresh_allowed_equipment_options()
	_sync_equipment_to_character()
	_revalidate_selected_feat()
	_recalculate_character_hp()
	_update_selection_buttons()
	_refresh_skills_ui()
	_refresh_feat_ui()
	_refresh_spells_ui()
	_refresh_equipment_ui()
	_refresh_ability_scores_ui()
	_update_next_button_state()
	_refresh_preview()


func _on_background_selected(index: int) -> void:
	if index < 0 or index >= available_backgrounds.size():
		return

	selected_background = available_backgrounds[index] as BackgroundResource
	_ensure_current_character()
	CharacterCreationManager.current_character.background = selected_background
	_refresh_allowed_equipment_options()
	_sync_equipment_to_character()
	_update_selection_buttons()
	_refresh_skills_ui()
	_refresh_feat_ui()
	_refresh_spells_ui()
	_refresh_equipment_ui()
	_refresh_ability_scores_ui()
	_update_next_button_state()
	_refresh_preview()


func _on_feat_inspect_requested(index: int) -> void:
	if index < 0 or index >= available_feats.size():
		return

	var feat := available_feats[index] as FeatResource
	_show_feat_details_popup(feat)


func _on_feat_details_select_pressed() -> void:
	if inspected_feat == null:
		return

	if selected_feat != null and selected_feat.resource_id == inspected_feat.resource_id:
		selected_feat = null
		_apply_feat_selection_refresh()
		feat_details_dialog.hide()
		return

	if _get_selected_feats_for_replacement().size() >= _get_max_selectable_feat_count():
		_open_feat_replace_dialog()
		return

	selected_feat = inspected_feat
	_apply_feat_selection_refresh()
	feat_details_dialog.hide()


func _on_feat_replace_confirmed() -> void:
	if inspected_feat == null or feat_replace_option.item_count <= 0:
		return

	var selected_index := feat_replace_option.selected
	var metadata = feat_replace_option.get_item_metadata(selected_index)
	var replacement_target_id: String = metadata if metadata is String else ""
	if replacement_target_id.is_empty():
		return

	if selected_feat != null and selected_feat.resource_id == replacement_target_id:
		selected_feat = inspected_feat
	else:
		selected_feat = inspected_feat

	_apply_feat_selection_refresh()
	feat_replace_dialog.hide()
	feat_details_dialog.hide()


func _on_feat_replace_cancel_pressed() -> void:
	feat_replace_dialog.hide()


func _apply_feat_selection_refresh() -> void:
	_revalidate_selected_feat()
	_recalculate_character_hp()
	_update_selection_buttons()
	_refresh_skills_ui()
	_refresh_feat_ui()
	_refresh_spells_ui()
	_refresh_ability_scores_ui()
	_update_next_button_state()
	_refresh_preview()


func _on_ability_score_changed(value: float, ability_key: String) -> void:
	var character := CharacterCreationManager.current_character
	_ensure_base_ability_scores(character)
	character.base_ability_scores[ability_key] = int(value)
	_revalidate_selected_feat()
	_recalculate_character_hp()
	_refresh_skills_ui()
	_refresh_ability_scores_ui()
	_refresh_feat_ui()
	_refresh_spells_ui()
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
	_refresh_skills_ui()
	_refresh_feat_ui()
	_refresh_spells_ui()
	_refresh_ability_scores_ui()
	_update_next_button_state()
	_refresh_preview()


func _on_magic_initiate_spell_list_selected(index: int) -> void:
	var metadata = magic_initiate_feat_spell_list_option.get_item_metadata(index)
	magic_initiate_spell_list = metadata if metadata is String else ""
	selected_feat_cantrip_ids.clear()
	selected_feat_level_one_spell_ids.clear()
	_refresh_feat_ui()
	_refresh_spells_ui()
	_update_next_button_state()
	_refresh_preview()


func _on_class_skill_toggled(resource_id: String) -> void:
	var required_count := _get_required_class_skill_choice_count()
	if required_count <= 0:
		return

	if selected_class_skill_ids.has(resource_id):
		selected_class_skill_ids.erase(resource_id)
	elif selected_class_skill_ids.size() < required_count:
		selected_class_skill_ids[resource_id] = true

	_refresh_skills_ui()
	_update_next_button_state()
	_refresh_preview()


func _on_class_spell_toggled(resource_id: String, spell_level: int) -> void:
	if spell_level == 0:
		_toggle_spell_selection(selected_class_cantrip_ids, resource_id, _get_required_class_cantrip_count())
	else:
		_toggle_spell_selection(selected_class_level_one_spell_ids, resource_id, _get_required_class_level_one_spell_count())

	_refresh_spells_ui()
	_update_next_button_state()
	_refresh_preview()


func _on_feat_spell_toggled(resource_id: String, spell_level: int) -> void:
	if spell_level == 0:
		_toggle_spell_selection(selected_feat_cantrip_ids, resource_id, 2)
	else:
		_toggle_spell_selection(selected_feat_level_one_spell_ids, resource_id, 1)

	_refresh_spells_ui()
	_update_next_button_state()
	_refresh_preview()


func _toggle_spell_selection(selected_ids: Dictionary, resource_id: String, limit: int) -> void:
	if selected_ids.has(resource_id):
		selected_ids.erase(resource_id)
		return

	if limit <= 0 or selected_ids.size() >= limit:
		return

	selected_ids[resource_id] = true


func _on_pack_selected(index: int) -> void:
	if index < 0 or index >= available_pack_items.size():
		return

	var pack := available_pack_items[index] as ItemResource
	if selected_pack != null and selected_pack.resource_id == pack.resource_id:
		selected_pack = null
	else:
		selected_pack = pack

	_sync_equipment_to_character()
	_update_selection_buttons()
	_refresh_equipment_ui()
	_update_next_button_state()
	_refresh_preview()


func _on_individual_item_toggled(resource_id: String) -> void:
	if selected_individual_item_ids.has(resource_id):
		selected_individual_item_ids.erase(resource_id)
	else:
		selected_individual_item_ids[resource_id] = true

	_sync_equipment_to_character()
	_refresh_equipment_ui()
	_update_next_button_state()
	_refresh_preview()


func _on_use_default_gold_toggled(_pressed: bool) -> void:
	use_default_starting_gold = use_default_gold_checkbox.button_pressed
	_sync_equipment_to_character()
	_refresh_equipment_ui()
	_update_next_button_state()
	_refresh_preview()


func _on_item_search_text_changed(_new_text: String) -> void:
	return


func _on_equipment_group_variant_selected(index: int, scope: String, group_id: String, selector: OptionButton) -> void:
	var metadata = selector.get_item_metadata(index)
	var variant_id: String = metadata if metadata is String else ""
	if variant_id.is_empty():
		_erase_equipment_group_state(scope, group_id)
	else:
		_set_equipment_group_state(scope, group_id, {
			"variant_id": variant_id,
			"selected_item_ids": [],
		})

	_sync_equipment_to_character()
	_refresh_equipment_ui()
	_update_next_button_state()
	_refresh_preview()


func _on_equipment_group_slot_selected(index: int, scope: String, group_id: String, slot_index: int, selector: OptionButton) -> void:
	var state: Dictionary = _get_equipment_choice_state(scope).get(group_id, {
		"variant_id": "",
		"selected_item_ids": [],
	})
	var metadata = selector.get_item_metadata(index)
	var selected_item_id: String = metadata if metadata is String else ""
	var selected_item_ids: Array[String] = []
	for item_id in state.get("selected_item_ids", []):
		selected_item_ids.append(str(item_id))
	selected_item_ids.resize(max(selected_item_ids.size(), slot_index + 1))
	selected_item_ids[slot_index] = selected_item_id
	_set_equipment_group_state(scope, group_id, {
		"variant_id": str(state.get("variant_id", "")),
		"selected_item_ids": selected_item_ids,
	})

	_sync_equipment_to_character()
	_refresh_equipment_ui()
	_update_next_button_state()
	_refresh_preview()


func _on_character_name_changed(new_text: String) -> void:
	_ensure_current_character()
	CharacterCreationManager.current_character.character_name = new_text
	_update_next_button_state()
	_refresh_preview()


func _on_create_character_pressed() -> void:
	if not _can_finalize_character():
		push_warning("Character creation is incomplete. Finish all required selections before creating the character.")
		return

	_ensure_current_character()
	_sync_skills_to_character()
	_sync_spells_to_character()
	_sync_equipment_to_character()
	_revalidate_selected_feat()
	_recalculate_character_hp()
	_refresh_summary_ui()

	var save_result: Dictionary = CharacterCreationManager.save_current_character()
	if bool(save_result.get("success", false)):
		print("Character created and saved successfully!")
	else:
		push_error("Failed to save character. Error code: %s" % str(save_result.get("error", ERR_CANT_CREATE)))


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
	selected_feat = null
	if not CharacterCreationManager.current_character.feats.is_empty():
		selected_feat = CharacterCreationManager.current_character.feats[0]
	_sync_variant_human_choices_from_character()
	_sync_skill_state_from_character()
	_sync_spell_state_from_character()
	_sync_equipment_state_from_character()
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


func _can_advance_from_skills_step() -> bool:
	if selected_class == null or selected_background == null:
		return false
	return selected_class_skill_ids.size() == _get_required_class_skill_choice_count()


func _can_advance_from_feats_step() -> bool:
	if _is_variant_human_selected():
		return selected_feat != null and selected_feat_valid and _has_valid_variant_human_bonus_choices() and _has_valid_feat_configuration()

	if selected_feat == null:
		return true

	return selected_feat_valid and _has_valid_feat_configuration()


func _can_advance_from_spells_step() -> bool:
	if not _has_spell_selection_requirements():
		return true

	return _is_current_spell_phase_complete()


func _can_advance_from_equipment_step() -> bool:
	if selected_class == null or selected_background == null:
		return false
	if not _are_equipment_choice_groups_complete(_get_background_equipment_choice_groups(), selected_background_equipment_choice_state):
		return false
	if use_default_starting_gold:
		return true
	return _are_equipment_choice_groups_complete(_get_class_equipment_choice_groups(), selected_class_equipment_choice_state)


func _can_finalize_character() -> bool:
	return selected_race != null \
		and selected_class != null \
		and selected_background != null \
		and _has_valid_character_name() \
		and _can_advance_from_skills_step() \
		and _calculate_point_buy_total() == 27 \
		and _can_advance_from_feats_step() \
		and _can_advance_from_spells_step() \
		and _can_advance_from_equipment_step()


func _has_valid_character_name() -> bool:
	var character := CharacterCreationManager.current_character
	return character != null and not character.character_name.strip_edges().is_empty()


func _is_selected_race(race: RaceResource) -> bool:
	return selected_race != null and race.resource_id == selected_race.resource_id


func _is_selected_class(class_resource: ClassResource) -> bool:
	return selected_class != null and class_resource.resource_id == selected_class.resource_id


func _is_selected_background(background: BackgroundResource) -> bool:
	return selected_background != null and background.resource_id == selected_background.resource_id


func _is_selected_feat(feat: FeatResource) -> bool:
	return selected_feat != null and feat.resource_id == selected_feat.resource_id


func _is_selected_pack(pack: ItemResource) -> bool:
	return selected_pack != null and pack.resource_id == selected_pack.resource_id


func _find_race_by_id(resource_id: String) -> RaceResource:
	for race in available_races:
		if race != null and race.resource_id == resource_id:
			return race
	return null


func _find_class_by_id(resource_id: String) -> ClassResource:
	for class_resource in available_classes:
		if class_resource != null and class_resource.resource_id == resource_id:
			return class_resource
	return null


func _find_background_by_id(resource_id: String) -> BackgroundResource:
	for background in available_backgrounds:
		if background != null and background.resource_id == resource_id:
			return background
	return null


func _find_feat_by_id(resource_id: String) -> FeatResource:
	for feat in available_feats:
		if feat != null and feat.resource_id == resource_id:
			return feat
	return null


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


func _format_feat_bonus_summary(feat: FeatResource) -> String:
	var parts: Array[String] = []
	var seen := {}

	var ability_increases := _format_feat_ability_score_increases(feat)
	if ability_increases != "None":
		seen[ability_increases] = true
		parts.append(ability_increases)

	for modifier in feat.modifiers:
		if modifier == null or modifier.modifier_type == StatModifier.Type.ABILITY_SCORE:
			continue
		var summary := _format_feat_modifier_summary(modifier)
		if summary.is_empty() or seen.has(summary):
			continue
		seen[summary] = true
		parts.append(summary)

	var special_rules := _format_feat_special_rules(feat.special_rules)
	if not special_rules.is_empty() and not seen.has(special_rules):
		parts.append(special_rules)

	return ", ".join(parts) if not parts.is_empty() else "None"


func _show_feat_details_popup(feat: FeatResource) -> void:
	if feat == null:
		return

	inspected_feat = feat
	feat_details_dialog.title = "Feat Details"
	feat_details_title_label.text = feat.display_name
	feat_details_prereq_value_label.text = _format_feat_prerequisites(feat)
	feat_details_description_value_label.text = feat.description if not feat.description.strip_edges().is_empty() else "No description provided yet."
	feat_details_mechanics_value.text = _format_feat_mechanics_popup_text(feat)
	feat_details_mechanics_value.scroll_to_line(0)

	if selected_feat != null and selected_feat.resource_id == feat.resource_id:
		if selected_feat_valid:
			feat_details_status_label.text = "Currently selected for this character."
			_set_label_color(feat_details_status_label, Color(0.2, 0.7, 0.3))
		else:
			feat_details_status_label.text = selected_feat_validation_message if not selected_feat_validation_message.is_empty() else "This feat is selected, but its prerequisites are not currently met."
			_set_label_color(feat_details_status_label, Color(0.85, 0.25, 0.25))
	else:
		feat_details_status_label.text = "Not currently selected."
		_set_label_color(feat_details_status_label, Color(0.7, 0.7, 0.7))

	feat_details_select_button.text = _get_feat_details_action_text(feat)
	feat_details_dialog.popup_centered_ratio(0.48)


func _get_feat_details_action_text(feat: FeatResource) -> String:
	if selected_feat != null and selected_feat.resource_id == feat.resource_id:
		return "Deselect Feat"
	if _get_selected_feats_for_replacement().size() >= _get_max_selectable_feat_count():
		return "Replace Current Feat"
	return "Select Feat"


func _get_max_selectable_feat_count() -> int:
	return 1


func _get_selected_feats_for_replacement() -> Array[FeatResource]:
	var feats: Array[FeatResource] = []
	if selected_feat != null:
		feats.append(selected_feat)
	return feats


func _open_feat_replace_dialog() -> void:
	feat_replace_option.clear()
	var selected_feats := _get_selected_feats_for_replacement()
	for feat in selected_feats:
		var option_index := feat_replace_option.item_count
		feat_replace_option.add_item(feat.display_name)
		feat_replace_option.set_item_metadata(option_index, feat.resource_id)
	if feat_replace_option.item_count > 0:
		feat_replace_option.select(0)
	feat_replace_label.text = "You already have the maximum number of feats selected. Choose which current feat to replace with %s." % inspected_feat.display_name
	feat_replace_confirm_button.text = "Replace With %s" % inspected_feat.display_name
	feat_details_dialog.hide()
	feat_replace_dialog.popup_centered()


func _format_feat_mechanics_popup_text(feat: FeatResource) -> String:
	var lines: Array[String] = []

	var ability_increases := _format_feat_ability_score_increases(feat)
	if ability_increases != "None":
		lines.append("[b]Ability Score Changes[/b]\n%s" % ability_increases)

	var other_modifier_lines: Array[String] = []
	for modifier in feat.modifiers:
		if modifier == null:
			continue
		var summary := _format_feat_popup_modifier_summary(modifier)
		if summary.is_empty():
			continue
		other_modifier_lines.append("- %s" % summary)
	if not other_modifier_lines.is_empty():
		lines.append("[b]Tracked Modifiers[/b]\n%s" % "\n".join(other_modifier_lines))

	var special_rules := feat.special_rules.strip_edges()
	if not special_rules.is_empty():
		lines.append("[b]Special Rules[/b]\n%s" % _format_feat_special_rules(special_rules))

	if lines.is_empty():
		return "Mechanical details will appear here as this feat's systems are implemented."

	lines.append("\nMechanical details in this panel will expand as feat systems are wired into gameplay.")
	return "\n\n".join(lines)


func _format_feat_popup_modifier_summary(modifier: StatModifier) -> String:
	if modifier.modifier_type == StatModifier.Type.ABILITY_SCORE and ABILITY_LABELS.has(modifier.target_key):
		return ""
	if modifier.modifier_type == StatModifier.Type.ABILITY_SCORE and not modifier.target_key.strip_edges().is_empty():
		return "%s %s" % [_format_feat_modifier_target(modifier.target_key), _format_signed_value(modifier.value)]
	return _format_feat_modifier_summary(modifier)


func _format_feat_modifier_summary(modifier: StatModifier) -> String:
	var target_label := _format_feat_modifier_target(modifier.target_key)
	match modifier.modifier_type:
		StatModifier.Type.PROFICIENCY:
			if target_label.is_empty():
				return "Proficiency"
			if modifier.target_key.begins_with("skill_"):
				return "%s proficiency" % target_label
			if ABILITY_LABELS.has(modifier.target_key):
				return "%s save proficiency" % target_label
			return "%s proficiency" % target_label
		StatModifier.Type.AC:
			return "AC %s" % _format_signed_value(modifier.value)
		StatModifier.Type.HP:
			return "HP %s" % _format_signed_value(modifier.value)
		StatModifier.Type.SPEED:
			return "Speed %s ft" % _format_signed_value(modifier.value)
		StatModifier.Type.DAMAGE:
			return "%s damage %s" % [target_label if not target_label.is_empty() else "Damage", _format_signed_value(modifier.value)]
		StatModifier.Type.SAVE:
			if target_label.is_empty():
				return "Saving throws %s" % _format_signed_value(modifier.value)
			return "%s saves %s" % [target_label, _format_signed_value(modifier.value)]
		StatModifier.Type.SKILL:
			if target_label.is_empty():
				return "Skill checks %s" % _format_signed_value(modifier.value)
			return "%s %s" % [target_label, _format_signed_value(modifier.value)]
		_:
			return ""


func _format_feat_modifier_target(target_key: String) -> String:
	var cleaned := target_key.strip_edges()
	if cleaned.is_empty():
		return ""
	if ABILITY_LABELS.has(cleaned):
		return ABILITY_LABELS[cleaned]
	if cleaned.begins_with("skill_"):
		return _get_skill_display_name(cleaned)
	return _title_case_identifier(cleaned)


func _format_feat_special_rules(special_rules: String) -> String:
	var cleaned := special_rules.strip_edges()
	if cleaned.is_empty():
		return ""
	if cleaned.contains("="):
		var parts := cleaned.split("=", true, 1)
		if parts.size() == 2:
			return "%s: %s" % [_title_case_identifier(parts[0].strip_edges()), parts[1].strip_edges()]
	return _title_case_identifier(cleaned)


func _title_case_identifier(value: String) -> String:
	var words: Array[String] = []
	for segment in value.replace("_", " ").split(" ", false):
		words.append(segment.capitalize())
	return " ".join(words)


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


func _format_spellcasting_preview(character: CharacterSheetResource, race: RaceResource) -> String:
	var spellcasting_ability := _get_effective_spellcasting_ability()
	if spellcasting_ability.is_empty():
		return "-"

	var total_score := _get_final_ability_score(character, race, spellcasting_ability)
	var modifier := AbilitySystem.get_modifier(total_score)
	return "%s %s" % [ABILITY_LABELS.get(spellcasting_ability, spellcasting_ability.to_upper()), _format_signed_value(modifier)]


func _format_ability_preview(character: CharacterSheetResource, race: RaceResource, ability_key: String) -> String:
	var total_score := _get_final_ability_score(character, race, ability_key)
	var total_bonus := _get_total_ability_bonus(character, race, ability_key)
	if total_bonus == 0:
		return str(total_score)
	return "%d (%s total)" % [total_score, _format_signed_value(total_bonus)]


func _format_known_spells_preview(character: CharacterSheetResource) -> String:
	if character == null or character.known_spells.is_empty():
		return "-"

	var cantrip_names: Array[String] = []
	var level_one_names: Array[String] = []
	for spell in character.known_spells:
		if spell == null:
			continue
		if spell.spell_level == 0:
			cantrip_names.append(spell.display_name)
		elif spell.spell_level == 1:
			level_one_names.append(spell.display_name)

	var parts: Array[String] = []
	if not cantrip_names.is_empty():
		parts.append("Cantrips: %s" % ", ".join(cantrip_names))
	if not level_one_names.is_empty():
		parts.append("Level 1: %s" % ", ".join(level_one_names))
	return " | ".join(parts) if not parts.is_empty() else "-"


func _format_summary_preview(character: CharacterSheetResource) -> String:
	if character == null:
		return "[b]No character data available.[/b]"

	var race := character.race
	var sections: Array[String] = []

	var identity_lines := [
		"Name: %s" % _get_character_name(character),
		"Race: %s" % (race.display_name if race != null else "-"),
		"Class: %s" % (character.class_resource.display_name if character.class_resource != null else "-"),
		"Background: %s" % (character.background.display_name if character.background != null else "-"),
		"Subclass: %s" % (character.subclass.display_name if character.subclass != null else "-"),
	]
	if race != null:
		identity_lines.append("Speed: %d ft" % race.speed)
		identity_lines.append("Darkvision: %s" % ("Yes" if race.darkvision else "No"))
	sections.append("[b]Character[/b]\n%s" % "\n".join(identity_lines))

	var stat_lines := [
		"HP: %s" % _format_hp_preview(character, race),
		"Proficiency Bonus: %s" % _format_signed_value(AbilitySystem.get_proficiency_bonus(max(character.current_level, 1))),
		"Spellcasting: %s" % _format_spellcasting_preview(character, race),
	]
	if character.class_resource != null:
		stat_lines.append("Saving Throws: %s" % _format_saving_throw_proficiencies(character.class_resource))
	sections.append("[b]Core Stats[/b]\n%s" % "\n".join(stat_lines))

	sections.append("[b]Ability Scores[/b]\n%s" % "\n".join(_format_summary_ability_lines(character, race)))
	sections.append("[b]Skills[/b]\n%s" % "\n".join(_format_summary_skill_lines(character, race)))
	sections.append("[b]Feats[/b]\n%s" % "\n".join(_format_summary_feat_lines(character)))
	sections.append("[b]Spells[/b]\n%s" % "\n".join(_format_summary_spell_lines(character)))
	sections.append("[b]Equipment & Gold[/b]\n%s" % "\n".join(_format_summary_equipment_lines(character)))
	return "\n\n".join(sections)


func _format_summary_ability_lines(character: CharacterSheetResource, race: RaceResource) -> Array[String]:
	var lines: Array[String] = []
	for ability_key in ABILITY_ORDER:
		var base_score := int(character.base_ability_scores.get(ability_key, 8))
		var total_bonus := _get_total_ability_bonus(character, race, ability_key)
		var final_score := _get_final_ability_score(character, race, ability_key)
		lines.append("%s: %d (Base %d, Bonuses %s)" % [ABILITY_LABELS[ability_key], final_score, base_score, _format_signed_value(total_bonus)])
	return lines


func _format_summary_skill_lines(character: CharacterSheetResource, race: RaceResource) -> Array[String]:
	if character.skill_proficiencies.is_empty():
		return ["- None"]

	var lines: Array[String] = []
	for skill_id in _get_sorted_skill_ids_from_array(character.skill_proficiencies):
		var source_labels := _get_skill_source_labels(character.skill_proficiency_sources.get(skill_id, []))
		var source_suffix := ""
		if not source_labels.is_empty():
			source_suffix = " (%s)" % ", ".join(source_labels)
		lines.append("- %s (%s)%s" % [_get_skill_display_name(skill_id), _format_signed_value(_get_skill_roll_modifier(character, race, skill_id)), source_suffix])
	return lines


func _format_summary_feat_lines(character: CharacterSheetResource) -> Array[String]:
	if character.feats.is_empty():
		return ["- None"]

	var lines: Array[String] = []
	for feat in character.feats:
		if feat != null:
			lines.append("- %s" % feat.display_name)
	return lines if not lines.is_empty() else ["- None"]


func _format_summary_spell_lines(character: CharacterSheetResource) -> Array[String]:
	var cantrip_names := _get_known_spell_names_for_level(character, 0)
	var level_one_names := _get_known_spell_names_for_level(character, 1)
	var lines: Array[String] = []
	lines.append("Cantrips: %s" % (", ".join(cantrip_names) if not cantrip_names.is_empty() else "-"))
	lines.append("Level 1: %s" % (", ".join(level_one_names) if not level_one_names.is_empty() else "-"))
	return lines


func _get_known_spell_names_for_level(character: CharacterSheetResource, spell_level: int) -> Array[String]:
	var spell_names: Array[String] = []
	if character == null:
		return spell_names

	for spell in character.known_spells:
		if spell != null and spell.spell_level == spell_level:
			spell_names.append(spell.display_name)
	spell_names.sort()
	return spell_names


func _format_summary_equipment_lines(character: CharacterSheetResource) -> Array[String]:
	var lines: Array[String] = ["Starting Gold: %s" % _format_gold_amount(_get_starting_gold_amount())]
	var inventory_entries := _get_inventory_display_entries(character)
	if inventory_entries.is_empty():
		lines.append("Inventory: -")
		return lines

	lines.append("Inventory:")
	for entry in inventory_entries:
		lines.append("- %s" % entry)
	return lines


func _format_skills_preview(character: CharacterSheetResource) -> String:
	if character == null or character.skill_proficiencies.is_empty():
		return " -"

	var proficiency_bonus := AbilitySystem.get_proficiency_bonus(max(character.current_level, 1))
	var parts: Array[String] = []
	parts.append("Proficiency Bonus: %s" % _format_signed_value(proficiency_bonus))
	for skill_id in _get_sorted_skill_ids_from_array(character.skill_proficiencies):
		var roll_modifier := _get_skill_roll_modifier(character, selected_race, skill_id)
		var source_labels := _get_skill_source_labels(character.skill_proficiency_sources.get(skill_id, []))
		if source_labels.is_empty():
			parts.append("- %s (%s)" % [_get_skill_display_name(skill_id), _format_signed_value(roll_modifier)])
		else:
			parts.append("- %s (%s, %s)" % [_get_skill_display_name(skill_id), _format_signed_value(roll_modifier), ", ".join(source_labels)])
	return "\n%s" % "\n".join(parts)


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


func _get_skill_roll_modifier(character: CharacterSheetResource, race: RaceResource, skill_id: String) -> int:
	if character == null:
		return 0

	var ability_key := _get_skill_ability_key(skill_id)
	var ability_score := _get_final_ability_score(character, race, ability_key)
	return AbilitySystem.get_modifier(ability_score) + AbilitySystem.get_proficiency_bonus(max(character.current_level, 1))


func _get_skill_ability_key(skill_id: String) -> String:
	var skill := skill_resource_cache.get(skill_id) as SkillResource
	if skill == null:
		var resource_path := "%s/%s.tres" % [SKILL_DATA_PATH, skill_id]
		skill = load(resource_path) as SkillResource
		if skill != null:
			skill_resource_cache[skill_id] = skill
	if skill != null and not skill.ability_key.is_empty():
		return skill.ability_key
	return "str"


func _get_required_class_skill_choice_count() -> int:
	if selected_class == null:
		return 0
	return max(selected_class.skill_proficiency_count, 0)


func _get_available_class_skill_choice_ids() -> Array[String]:
	var available_ids: Array[String] = []
	var automatic_skill_sources := _get_automatic_skill_source_map()
	for skill in available_skills:
		if skill == null:
			continue
		if automatic_skill_sources.has(skill.resource_id):
			continue
		available_ids.append(skill.resource_id)
	return _get_sorted_skill_ids_from_array(available_ids)


func _get_automatic_skill_source_map() -> Dictionary:
	var source_map := {}
	_append_background_skill_sources(source_map)
	_append_modifier_skill_sources(source_map, selected_race.modifiers if selected_race != null else [], "Race")
	_append_modifier_skill_sources(source_map, selected_class.modifiers if selected_class != null else [], "Class")
	for feat in _get_active_feats():
		_append_modifier_skill_sources(source_map, feat.modifiers, "Feat")

	if _has_selected_feat_id("feat_skilled"):
		var skilled_ids := _get_skilled_feat_auto_skill_ids(source_map)
		for skill_id in skilled_ids:
			_append_skill_source(source_map, skill_id, "Feat")

	return source_map


func _append_background_skill_sources(source_map: Dictionary) -> void:
	if selected_background == null:
		return

	for skill_id in selected_background.skill_proficiencies:
		_append_skill_source(source_map, skill_id, "Background")
	_append_modifier_skill_sources(source_map, selected_background.modifiers, "Background")


func _append_modifier_skill_sources(source_map: Dictionary, modifiers: Array, source_label: String) -> void:
	for modifier in modifiers:
		if modifier == null:
			continue
		if modifier.value <= 0:
			continue
		if modifier.target_key.is_empty() or not modifier.target_key.begins_with("skill_"):
			continue
		_append_skill_source(source_map, modifier.target_key, source_label)


func _append_skill_source(source_map: Dictionary, skill_id: String, source_label: String) -> void:
	if skill_id.is_empty():
		return

	var labels := _get_skill_source_labels(source_map.get(skill_id, []))
	if labels.has(source_label):
		source_map[skill_id] = labels
		return
	labels.append(source_label)
	source_map[skill_id] = labels


func _get_skilled_feat_auto_skill_ids(existing_source_map: Dictionary) -> Array[String]:
	var skill_ids: Array[String] = []
	for candidate_id in _get_sorted_skill_ids_from_array(_get_all_skill_ids()):
		if existing_source_map.has(candidate_id):
			continue
		skill_ids.append(candidate_id)
		if skill_ids.size() >= 3:
			break
	return skill_ids


func _get_final_skill_source_map() -> Dictionary:
	var source_map := _get_automatic_skill_source_map()
	for skill_id in _get_sorted_skill_ids_from_dictionary(selected_class_skill_ids):
		_append_skill_source(source_map, skill_id, "Class")
	return source_map


func _sync_skill_state_from_character() -> void:
	selected_class_skill_ids.clear()
	var character := CharacterCreationManager.current_character
	if character == null:
		return

	var selection_state: Dictionary = character.skill_selection_state
	var stored_choices: Variant = selection_state.get("class_choices", [])
	if stored_choices is Array:
		for value in stored_choices:
			if value is String:
				selected_class_skill_ids[value] = true


func _sync_skills_to_character() -> void:
	var character := CharacterCreationManager.current_character
	if character == null:
		return

	var source_map := _get_final_skill_source_map()
	var skill_ids := _get_sorted_skill_ids_from_source_map(source_map)
	character.skill_proficiencies = skill_ids
	character.skill_proficiency_sources.clear()
	for skill_id in skill_ids:
		character.skill_proficiency_sources[skill_id] = _get_skill_source_labels(source_map.get(skill_id, []))
	character.skill_selection_state = {
		"class_choices": _get_sorted_skill_ids_from_dictionary(selected_class_skill_ids),
	}


func _get_active_feats() -> Array:
	var feats: Array = []
	if selected_feat != null and selected_feat_valid:
		feats.append(selected_feat)
	return feats


func _has_selected_feat_id(resource_id: String) -> bool:
	for feat in _get_active_feats():
		if feat != null and feat.resource_id == resource_id:
			return true
	return false


func _collect_string_id_set(values: Array[String]) -> Dictionary:
	var ids := {}
	for value in values:
		ids[value] = true
	return ids


func _trim_selected_string_ids(selected_ids: Dictionary, limit: int) -> void:
	if limit < 0:
		return
	var resource_ids := _get_sorted_skill_ids_from_dictionary(selected_ids)
	for index in range(limit, resource_ids.size()):
		selected_ids.erase(resource_ids[index])


func _get_all_skill_ids() -> Array[String]:
	var skill_ids: Array[String] = []
	for skill in available_skills:
		if skill != null:
			skill_ids.append(skill.resource_id)
	return skill_ids


func _get_sorted_skill_ids_from_source_map(source_map: Dictionary) -> Array[String]:
	var skill_ids: Array[String] = []
	for skill_id in source_map.keys():
		if skill_id is String:
			skill_ids.append(skill_id)
	return _get_sorted_skill_ids_from_array(skill_ids)


func _get_sorted_skill_ids_from_dictionary(source: Dictionary) -> Array[String]:
	var skill_ids: Array[String] = []
	for skill_id in source.keys():
		if skill_id is String:
			skill_ids.append(skill_id)
	return _get_sorted_skill_ids_from_array(skill_ids)


func _get_sorted_skill_ids_from_array(skill_ids: Array) -> Array[String]:
	var sorted_skill_ids: Array[String] = []
	for skill_id in skill_ids:
		if skill_id is String and not skill_id.is_empty():
			sorted_skill_ids.append(skill_id)
	sorted_skill_ids.sort_custom(_sort_skill_ids_by_display_name)
	return sorted_skill_ids


func _sort_skill_ids_by_display_name(left: String, right: String) -> bool:
	var left_name := _get_skill_display_name(left).to_lower()
	var right_name := _get_skill_display_name(right).to_lower()
	if left_name == right_name:
		return left < right
	return left_name < right_name


func _get_skill_source_labels(value: Variant) -> Array[String]:
	var labels: Array[String] = []
	if value is Array:
		for entry in value:
			if entry is String and not entry.is_empty() and not labels.has(entry):
				labels.append(entry)
	elif value is String and not value.is_empty():
		labels.append(value)
	return labels


func _item_matches_search(item: ItemResource, search_text: String) -> bool:
	if search_text.is_empty():
		return true

	var haystack := "%s %s" % [item.display_name.to_lower(), item.description.to_lower()]
	return haystack.contains(search_text)


func _format_item_meta(item: ItemResource) -> String:
	match item.category:
		ItemResource.Category.WEAPON:
			return "%s %s | %s gp" % [item.damage_die, item.damage_type, str(item.cost_gp)]
		ItemResource.Category.ARMOR:
			return "AC %d | %s gp" % [item.armor_class, str(item.cost_gp)]
		ItemResource.Category.TOOL:
			return "Tool | %s gp" % str(item.cost_gp)
		_:
			return "%s gp" % str(item.cost_gp)


func _has_class_spellcasting() -> bool:
	return selected_class != null and not selected_class.spellcasting_ability.strip_edges().is_empty()


func _has_bonus_spell_selection_requirements() -> bool:
	return _requires_magic_initiate_spell_selection() and not magic_initiate_spell_list.is_empty()


func _requires_magic_initiate_spell_selection() -> bool:
	return selected_feat != null and selected_feat_valid and selected_feat.resource_id == FEAT_MAGIC_INITIATE_ID


func _has_valid_feat_configuration() -> bool:
	if _requires_magic_initiate_spell_selection():
		return not magic_initiate_spell_list.is_empty()
	return true


func _has_spell_selection_requirements() -> bool:
	return _has_class_spellcasting() or _has_bonus_spell_selection_requirements()


func _get_spell_phases() -> Array[String]:
	var phases: Array[String] = []
	if _get_required_class_cantrip_count() > 0:
		phases.append(SPELL_PHASE_CLASS_CANTRIPS)
	if _get_required_class_level_one_spell_count() > 0:
		phases.append(SPELL_PHASE_CLASS_LEVEL_ONE)
	if _has_bonus_spell_selection_requirements():
		phases.append(SPELL_PHASE_BONUS_CANTRIPS)
		phases.append(SPELL_PHASE_BONUS_LEVEL_ONE)
	return phases


func _normalize_spell_phase() -> void:
	var phases := _get_spell_phases()
	if phases.is_empty():
		current_spell_phase = ""
		return
	if phases.has(current_spell_phase):
		return
	for phase in phases:
		if not _is_spell_phase_complete(phase):
			current_spell_phase = phase
			return
	current_spell_phase = phases[0]


func _advance_spell_phase() -> bool:
	var phases := _get_spell_phases()
	if phases.is_empty():
		return false

	var current_index := phases.find(current_spell_phase)
	if current_index == -1:
		current_spell_phase = phases[0]
		_update_main_content()
		_refresh_spells_ui()
		_update_next_button_state()
		return true
	if current_index >= phases.size() - 1:
		return false

	current_spell_phase = phases[current_index + 1]
	_update_main_content()
	_refresh_spells_ui()
	_update_next_button_state()
	return true


func _retreat_spell_phase() -> bool:
	var phases := _get_spell_phases()
	if phases.is_empty():
		return false

	var current_index := phases.find(current_spell_phase)
	if current_index <= 0:
		return false

	current_spell_phase = phases[current_index - 1]
	_update_main_content()
	_refresh_spells_ui()
	_update_next_button_state()
	return true


func _revert_current_spell_phase_and_retreat() -> bool:
	if current_spell_phase.is_empty():
		return false

	_clear_spell_phase_selection(current_spell_phase)
	var did_retreat := _retreat_spell_phase()
	if did_retreat:
		_refresh_spells_ui()
		_update_next_button_state()
		_refresh_preview()
		return true

	go_to_step(5)
	return true


func _is_last_spell_phase() -> bool:
	var phases := _get_spell_phases()
	return not phases.is_empty() and current_spell_phase == phases[phases.size() - 1]


func _is_class_spell_phase(phase: String) -> bool:
	return phase == SPELL_PHASE_CLASS_CANTRIPS or phase == SPELL_PHASE_CLASS_LEVEL_ONE


func _is_bonus_spell_phase(phase: String) -> bool:
	return phase == SPELL_PHASE_BONUS_CANTRIPS or phase == SPELL_PHASE_BONUS_LEVEL_ONE


func _is_current_spell_phase_complete() -> bool:
	return _is_spell_phase_complete(current_spell_phase)


func _is_spell_phase_complete(phase: String) -> bool:
	match phase:
		SPELL_PHASE_CLASS_CANTRIPS:
			return selected_class_cantrip_ids.size() == _get_required_class_cantrip_count()
		SPELL_PHASE_CLASS_LEVEL_ONE:
			return selected_class_level_one_spell_ids.size() == _get_required_class_level_one_spell_count()
		SPELL_PHASE_BONUS_CANTRIPS:
			return selected_feat_cantrip_ids.size() == 2
		SPELL_PHASE_BONUS_LEVEL_ONE:
			return selected_feat_level_one_spell_ids.size() == 1
		_:
			return true


func _clear_spell_phase_selection(phase: String) -> void:
	match phase:
		SPELL_PHASE_CLASS_CANTRIPS:
			selected_class_cantrip_ids.clear()
		SPELL_PHASE_CLASS_LEVEL_ONE:
			selected_class_level_one_spell_ids.clear()
		SPELL_PHASE_BONUS_CANTRIPS:
			selected_feat_cantrip_ids.clear()
		SPELL_PHASE_BONUS_LEVEL_ONE:
			selected_feat_level_one_spell_ids.clear()


func _get_current_spell_phase_status_text() -> String:
	match current_spell_phase:
		SPELL_PHASE_CLASS_CANTRIPS:
			return "Select %d class cantrip(s)." % _get_required_class_cantrip_count()
		SPELL_PHASE_CLASS_LEVEL_ONE:
			return "Select %d class level 1 spell(s)." % _get_required_class_level_one_spell_count()
		SPELL_PHASE_BONUS_CANTRIPS:
			return "Select 2 bonus cantrips from your feat or feature."
		SPELL_PHASE_BONUS_LEVEL_ONE:
			return "Select 1 bonus level 1 spell from your feat or feature."
		_:
			return "No spell selection required for this build."


func _get_spell_phase_title() -> String:
	match current_spell_phase:
		SPELL_PHASE_CLASS_CANTRIPS:
			return "Class Cantrips"
		SPELL_PHASE_CLASS_LEVEL_ONE:
			return "Class Level 1 Spells"
		SPELL_PHASE_BONUS_CANTRIPS:
			return "Bonus Cantrips"
		SPELL_PHASE_BONUS_LEVEL_ONE:
			return "Bonus Level 1 Spells"
		_:
			return "Spells Selection"


func _get_effective_spellcasting_ability() -> String:
	if selected_class != null and not selected_class.spellcasting_ability.strip_edges().is_empty():
		return selected_class.spellcasting_ability
	if not magic_initiate_spell_list.is_empty():
		var feat_class := _find_class_by_id(magic_initiate_spell_list)
		if feat_class != null:
			return feat_class.spellcasting_ability
	return ""


func _get_required_class_cantrip_count() -> int:
	if not _has_class_spellcasting():
		return 0
	return max(selected_class.cantrips_known, 0)


func _get_required_class_level_one_spell_count() -> int:
	if not _has_class_spellcasting():
		return 0
	return max(_get_spells_known_for_level(selected_class, 1), 0)


func _get_spells_known_for_level(class_resource: ClassResource, spell_level: int) -> int:
	if class_resource == null:
		return 0
	if class_resource.spells_known_per_level.has(spell_level):
		return int(class_resource.spells_known_per_level[spell_level])
	var spell_level_key := str(spell_level)
	if class_resource.spells_known_per_level.has(spell_level_key):
		return int(class_resource.spells_known_per_level[spell_level_key])
	return 0


func _sanitize_spell_selection_state() -> void:
	_filter_selected_ids(selected_class_cantrip_ids, _collect_spell_id_set(_get_class_spells_by_level(0)))
	_filter_selected_ids(selected_class_level_one_spell_ids, _collect_spell_id_set(_get_class_spells_by_level(1)))
	_trim_selected_spell_ids(selected_class_cantrip_ids, _get_required_class_cantrip_count())
	_trim_selected_spell_ids(selected_class_level_one_spell_ids, _get_required_class_level_one_spell_count())

	if not _requires_magic_initiate_spell_selection():
		magic_initiate_spell_list = ""
		selected_feat_cantrip_ids.clear()
		selected_feat_level_one_spell_ids.clear()
		return

	var valid_magic_initiate_lists := _get_magic_initiate_spell_list_ids()
	if not valid_magic_initiate_lists.has(magic_initiate_spell_list):
		magic_initiate_spell_list = ""

	_filter_selected_ids(selected_feat_cantrip_ids, _collect_spell_id_set(_get_magic_initiate_spells_by_level(0)))
	_filter_selected_ids(selected_feat_level_one_spell_ids, _collect_spell_id_set(_get_magic_initiate_spells_by_level(1)))
	_trim_selected_spell_ids(selected_feat_cantrip_ids, 2)
	_trim_selected_spell_ids(selected_feat_level_one_spell_ids, 1)


func _filter_selected_ids(selected_ids: Dictionary, valid_ids: Dictionary) -> void:
	for resource_id in selected_ids.keys():
		if not valid_ids.has(resource_id):
			selected_ids.erase(resource_id)


func _trim_selected_spell_ids(selected_ids: Dictionary, limit: int) -> void:
	if limit < 0:
		return
	var resource_ids := selected_ids.keys()
	resource_ids.sort()
	for index in range(limit, resource_ids.size()):
		selected_ids.erase(resource_ids[index])


func _collect_spell_id_set(spells: Array) -> Dictionary:
	var spell_ids := {}
	for spell in spells:
		if spell != null:
			spell_ids[spell.resource_id] = true
	return spell_ids


func _get_class_spells_by_level(spell_level: int) -> Array:
	if selected_class == null:
		return []
	return _get_spells_for_list(selected_class.resource_id, spell_level)


func _get_magic_initiate_spells_by_level(spell_level: int) -> Array:
	if magic_initiate_spell_list.is_empty():
		return []
	return _get_spells_for_list(magic_initiate_spell_list, spell_level)


func _get_spells_for_list(list_id: String, spell_level: int) -> Array:
	var spells: Array = []
	for spell in available_spells:
		if spell == null or spell.spell_level != spell_level:
			continue
		if not spell.spell_lists.has(list_id):
			continue
		spells.append(spell)
	return spells


func _get_magic_initiate_spell_list_ids() -> Array[String]:
	var list_ids: Array[String] = []
	var seen := {}
	for spell in available_spells:
		if spell == null or (spell.spell_level != 0 and spell.spell_level != 1):
			continue
		for list_id in spell.spell_lists:
			if seen.has(list_id):
				continue
			seen[list_id] = true
			list_ids.append(list_id)
	list_ids.sort()
	return list_ids


func _populate_magic_initiate_spell_list_option() -> void:
	magic_initiate_feat_spell_list_option.clear()
	magic_initiate_feat_spell_list_option.add_item("Choose a spell list")
	magic_initiate_feat_spell_list_option.set_item_metadata(0, "")

	for list_id in _get_magic_initiate_spell_list_ids():
		var item_index := magic_initiate_feat_spell_list_option.item_count
		magic_initiate_feat_spell_list_option.add_item(_get_class_display_name_by_id(list_id))
		magic_initiate_feat_spell_list_option.set_item_metadata(item_index, list_id)

	_select_option_by_metadata(magic_initiate_feat_spell_list_option, magic_initiate_spell_list)


func _select_option_by_metadata(selector: OptionButton, value: String) -> void:
	for index in range(selector.item_count):
		if selector.get_item_metadata(index) == value:
			selector.select(index)
			return
	selector.select(0)


func _get_class_display_name_by_id(class_id: String) -> String:
	for class_resource in available_classes:
		if class_resource != null and class_resource.resource_id == class_id:
			return class_resource.display_name
	return class_id.trim_prefix("class_").replace("_", " ").capitalize()


func _sync_spell_state_from_character() -> void:
	selected_class_cantrip_ids.clear()
	selected_class_level_one_spell_ids.clear()
	selected_feat_cantrip_ids.clear()
	selected_feat_level_one_spell_ids.clear()
	magic_initiate_spell_list = ""

	var character := CharacterCreationManager.current_character
	if character == null:
		return

	var selection_state := character.spell_selection_state
	_load_selected_spell_ids(selected_class_cantrip_ids, selection_state.get("class_cantrips", []))
	_load_selected_spell_ids(selected_class_level_one_spell_ids, selection_state.get("class_level_one", []))
	_load_selected_spell_ids(selected_feat_cantrip_ids, selection_state.get("feat_cantrips", []))
	_load_selected_spell_ids(selected_feat_level_one_spell_ids, selection_state.get("feat_level_one", []))
	if selection_state.get("magic_initiate_spell_list", "") is String:
		magic_initiate_spell_list = selection_state.get("magic_initiate_spell_list", "")


func _load_selected_spell_ids(selected_ids: Dictionary, values: Variant) -> void:
	if values is Array:
		for value in values:
			if value is String:
				selected_ids[value] = true


func _sync_spells_to_character() -> void:
	var character := CharacterCreationManager.current_character
	if character == null:
		return

	character.known_spells.clear()
	var seen := {}
	_append_selected_spells(character.known_spells, seen, selected_class_cantrip_ids)
	_append_selected_spells(character.known_spells, seen, selected_class_level_one_spell_ids)
	_append_selected_spells(character.known_spells, seen, selected_feat_cantrip_ids)
	_append_selected_spells(character.known_spells, seen, selected_feat_level_one_spell_ids)
	character.spell_selection_state = {
		"class_cantrips": _get_sorted_selected_spell_ids(selected_class_cantrip_ids),
		"class_level_one": _get_sorted_selected_spell_ids(selected_class_level_one_spell_ids),
		"feat_cantrips": _get_sorted_selected_spell_ids(selected_feat_cantrip_ids),
		"feat_level_one": _get_sorted_selected_spell_ids(selected_feat_level_one_spell_ids),
		"magic_initiate_spell_list": magic_initiate_spell_list,
	}


func _append_selected_spells(target: Array[SpellResource], seen: Dictionary, selected_ids: Dictionary) -> void:
	for resource_id in _get_sorted_selected_spell_ids(selected_ids):
		if seen.has(resource_id):
			continue
		var spell := spell_resource_cache.get(resource_id) as SpellResource
		if spell == null:
			continue
		target.append(spell)
		seen[resource_id] = true


func _get_sorted_selected_spell_ids(selected_ids: Dictionary) -> Array[String]:
	var resource_ids: Array[String] = []
	for resource_id in selected_ids.keys():
		resource_ids.append(resource_id)
	resource_ids.sort()
	return resource_ids


func _format_spell_level_label(spell_level: int) -> String:
	if spell_level <= 0:
		return "Cantrip"
	return "Level %d" % spell_level


func _sync_equipment_state_from_character() -> void:
	selected_pack = null
	selected_individual_item_ids.clear()
	selected_class_equipment_choice_state.clear()
	selected_background_equipment_choice_state.clear()
	use_default_starting_gold = false

	var character := CharacterCreationManager.current_character
	if character == null:
		return

	var selection_state: Dictionary = character.equipment_selection_state
	use_default_starting_gold = bool(selection_state.get("use_default_starting_gold", false))
	_load_equipment_choice_state(selection_state.get("class_choice_state", {}), selected_class_equipment_choice_state)
	_load_equipment_choice_state(selection_state.get("background_choice_state", {}), selected_background_equipment_choice_state)
	_sanitize_class_equipment_choice_state()


func _sync_equipment_to_character() -> void:
	var character := CharacterCreationManager.current_character
	if character == null:
		return

	character.inventory.clear()
	for item_id in _get_equipment_item_ids_for_character():
		var selected_item := selected_item_resources.get(item_id) as ItemResource
		if selected_item != null:
			character.inventory.append(selected_item)
	character.equipment_selection_state = {
		"use_default_starting_gold": use_default_starting_gold,
		"class_choice_state": _duplicate_equipment_choice_state(selected_class_equipment_choice_state),
		"background_choice_state": _duplicate_equipment_choice_state(selected_background_equipment_choice_state),
	}


func _update_equipment_status() -> void:
	if selected_class == null or selected_background == null:
		equipment_status_label.text = "Select a class and background before choosing starting equipment."
		_set_label_color(equipment_status_label, Color(0.85, 0.65, 0.2))
		return

	if not _are_equipment_choice_groups_complete(_get_background_equipment_choice_groups(), selected_background_equipment_choice_state):
		equipment_status_label.text = "Complete each background starter equipment choice."
		_set_label_color(equipment_status_label, Color(0.85, 0.65, 0.2))
		return

	if use_default_starting_gold:
		equipment_status_label.text = "Using class starting gold (%s) plus background gold and background equipment." % _format_gold_amount(_parse_gold_expression(selected_class.starting_gold_dice))
		_set_label_color(equipment_status_label, Color(0.2, 0.7, 0.3))
		return

	if not _are_equipment_choice_groups_complete(_get_class_equipment_choice_groups(), selected_class_equipment_choice_state):
		equipment_status_label.text = "Complete each class starter equipment choice or switch to starting gold."
		_set_label_color(equipment_status_label, Color(0.85, 0.65, 0.2))
		return

	equipment_status_label.text = "Starter equipment selections complete."
	_set_label_color(equipment_status_label, Color(0.2, 0.7, 0.3))


func _refresh_inventory_gold_preview(character: CharacterSheetResource) -> void:
	for child in inventory_items_container.get_children():
		child.queue_free()

	var inventory_entries := _get_inventory_display_entries(character)
	if inventory_entries.is_empty():
		var empty_label := Label.new()
		empty_label.text = "None"
		inventory_items_container.add_child(empty_label)
	else:
		for entry in inventory_entries:
			var item_label := Label.new()
			item_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			item_label.text = "- %s" % entry
			inventory_items_container.add_child(item_label)

	inventory_gold_amount_label.text = "Gold: %s" % _format_gold_amount(_get_starting_gold_amount())


func _get_inventory_display_entries(character: CharacterSheetResource) -> Array[String]:
	var entries: Array[String] = []
	if character == null:
		return entries

	var counts := {}
	var ordered_ids: Array[String] = []
	var names := {}
	for item in character.inventory:
		if item == null:
			continue
		var stack_data := _get_item_stack_display_data(item)
		var stack_key := str(stack_data["key"])
		if not counts.has(stack_key):
			counts[stack_key] = 0
			ordered_ids.append(stack_key)
			names[stack_key] = str(stack_data["name"])
		counts[stack_key] = int(counts[stack_key]) + int(stack_data["quantity"])

	for stack_key in ordered_ids:
		var count := int(counts.get(stack_key, 0))
		var display_name := str(names.get(stack_key, stack_key))
		if count > 1:
			entries.append("%s x%d" % [display_name, count])
		else:
			entries.append(display_name)
	return entries


func _get_item_stack_display_data(item: ItemResource) -> Dictionary:
	var display_name := item.display_name if item != null else ""
	var quantity := 1
	var stack_name := display_name
	var quantity_match := RegEx.new()
	quantity_match.compile("^(.*)\\((\\d+)\\)\\s*$")
	var result := quantity_match.search(display_name)
	if result != null:
		stack_name = result.get_string(1).strip_edges()
		quantity = max(int(result.get_string(2)), 1)

	return {
		"key": "%s::%s" % [item.resource_id if item != null else "item", stack_name],
		"name": stack_name,
		"quantity": quantity,
	}


func _get_starting_gold_amount() -> float:
	var total := 0.0
	if use_default_starting_gold and selected_class != null:
		total += _parse_gold_expression(selected_class.starting_gold_dice)
	if selected_background != null:
		total += _parse_gold_expression(selected_background.starting_gold_dice)
	return total


func _parse_gold_expression(expression: String) -> float:
	var cleaned := expression.strip_edges()
	if cleaned.is_empty():
		return 0.0

	var dice_regex := RegEx.new()
	dice_regex.compile("(?i)(\\d+)d(\\d+)(?:\\s*[×x]\\s*(\\d+(?:\\.\\d+)?))?")
	var dice_match := dice_regex.search(cleaned)
	if dice_match:
		var dice_count := float(dice_match.get_string(1))
		var dice_sides := float(dice_match.get_string(2))
		var multiplier := 1.0
		if dice_match.get_string(3) != "":
			multiplier = float(dice_match.get_string(3))
		return dice_count * ((dice_sides + 1.0) / 2.0) * multiplier

	var number_regex := RegEx.new()
	number_regex.compile("(\\d+(?:\\.\\d+)?)")
	var number_match := number_regex.search(cleaned)
	if number_match:
		return float(number_match.get_string(1))

	return 0.0


func _format_gold_amount(amount: float) -> String:
	if is_equal_approx(amount, round(amount)):
		return "%d gp" % int(round(amount))
	return "%.1f gp" % amount


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


func _update_magic_initiate_status() -> void:
	if not _requires_magic_initiate_spell_selection():
		return

	if magic_initiate_spell_list.is_empty():
		magic_initiate_description_label.text = "Choose the spell list for Magic Initiate before moving on."
		_set_label_color(magic_initiate_description_label, Color(0.85, 0.65, 0.2))
	else:
		magic_initiate_description_label.text = "Magic Initiate will use the %s spell list." % _get_class_display_name_by_id(magic_initiate_spell_list)
		_set_label_color(magic_initiate_description_label, Color(0.2, 0.7, 0.3))


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
		if _requires_magic_initiate_spell_selection() and magic_initiate_spell_list.is_empty():
			feat_status_label.text = "Selected feat: %s. Choose a spell list to continue." % selected_feat.display_name
			_set_label_color(feat_status_label, Color(0.85, 0.65, 0.2))
		else:
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
