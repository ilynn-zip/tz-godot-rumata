extends Node

const SAVE_PATH = "user://rumatasavegame.json"

var load_save : = false

# сохранение игры
func save_game(map_seed : int, player : CharacterBody2D, enemies : Array,
			coins : Array, collected_coin : int) -> void:
	var data = {}
	
	# уровень сохраняется сидом
	data["level"] = {
		"seed": map_seed,
	}

	# игрок
	data["player"] = {
		"position": [player.global_position.x, player.global_position.y],
		"rotation": player.global_rotation,
		"collected_coin": collected_coin
	}

	# враги
	data["enemies"] = []
	for e in enemies:
		data["enemies"].append({
			"position": [e.global_position.x, e.global_position.y]
		})

	# монетки
	data["coins"] = []
	for c in coins:
		data["coins"].append({
			"position": [c.global_position.x, c.global_position.y]
		})

	# запись в файл
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	print("Игра сохранена!")

# загрузка сохранеия
func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Сохранение не найдено")
		return {}

	load_save = true

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var result = JSON.parse_string(content)
	if typeof(result) == TYPE_DICTIONARY:
		print("загрузка успешна")
		return result
	else:
		print("Ошибка загрузки сохранения")
		return {}
