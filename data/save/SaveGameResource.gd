@tool
extends TTResource
class_name SaveGameResource

const KIND_MANUAL := "manual"
const KIND_QUICKSAVE := "quicksave"
const KIND_AUTOSAVE := "autosave"
const KIND_CHECKPOINT := "checkpoint"
const KIND_TEST_FIXTURE := "test_fixture"

@export var save_id: String = ""
@export var parent_save_id: String = ""
@export var character_id: String = ""
@export var campaign_id: String = ""
@export var slot_name: String = ""
@export var save_kind: String = KIND_MANUAL
@export var created_at_unix: int = 0
@export var notes: String = ""
@export var character_name: String = ""
@export var character_level: int = 1
@export var metadata: Dictionary = {}
@export var character_state: CharacterSheetResource
