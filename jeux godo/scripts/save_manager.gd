extends Node

const SAVE_PATH := "user://save.json"

static func _read_data() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return {}
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    var text := file.get_as_text()
    var data = JSON.parse_string(text)
    return data if data is Dictionary else {}

static func _write_data(data: Dictionary) -> void:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    file.store_string(JSON.stringify(data))

static func get_best_score(game_id: String) -> int:
    var data := _read_data()
    return int(data.get(game_id, 0))

static func set_best_score(game_id: String, score: int) -> void:
    var data := _read_data()
    data[game_id] = score
    _write_data(data)
