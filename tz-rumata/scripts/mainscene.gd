extends Node2D

@onready var level: Node2D = $Level
@onready var player: Player = $Player
@onready var pause_menu: Control = $CanvasLayer/PauseMenu

func _ready() -> void:
	get_tree().paused = false
	# подключаем сигналы победы и проигрыша игрока
	player.connect("player_dead", _on_player_dead)
	player.connect("player_win", _on_player_win)
	pause_menu.hide()
	
	# настройка границ камеры
	player.camera.limit_left = 0
	player.camera.limit_top = 0
	player.camera.limit_right = (Config.width + 1) * level.tile_map_layer.tile_set.tile_size.x
	player.camera.limit_bottom = (Config.height + 1) * level.tile_map_layer.tile_set.tile_size.y
	
	# проверка если мы загружаем имеющееся сохранение
	if SaveManager.load_save:
		load_save()

# загрузка параметров сохранения
func load_save():
	var data = SaveManager.load_game()
	if data.is_empty():
		return
	
	# установка сида для повторной генерации карты
	level.custom_seed = data["level"]["seed"]
	
	# возврщаем позицию игрока
	player.global_position = Vector2(data["player"]["position"][0], data["player"]["position"][1])
	player.global_rotation = data["player"]["rotation"]
	player.collected_coin = data["player"]["collected_coin"]
	player.update_coins()
	
	# удаляем имеющихся врагов и спавним их фалй сохранения
	for e in get_tree().get_nodes_in_group("Enemies"):
		e.queue_free()
	for enemy_data in data["enemies"]:
		var enemy = level.enemy_scene.instantiate()
		enemy.global_position = Vector2(enemy_data["position"][0], enemy_data["position"][1])
		level.enemies.add_child(enemy)
	
	# удаляем имеющиеся монеты и спавним их фалй сохранения
	for c in get_tree().get_nodes_in_group("Coins"):
		c.queue_free()
	for coin_data in data["coins"]:
		var coin = level.coin_scene.instantiate()
		coin.global_position = Vector2(coin_data["position"][0], coin_data["position"][1])
		level.coins.add_child(coin)
		
	SaveManager.load_save = false
	
	level.generate_dungeon()

func _input(event: InputEvent) -> void:
	# escape пауза
	if event.is_action_pressed("ui_cancel"):
		set_pause()

# показываем меню паузы
func set_pause():
	if pause_menu.visible:
		if pause_menu.type == pause_menu.SCREENTYPE.PAUSE:
			get_tree().paused = false
			pause_menu.hide()
	else:
		pause_menu.show()
		get_tree().paused = true

# при вызове сохранения передаем данные в файл сохранения
# сохранение происходит автоматически при нажатии выхода в меню паузы
func save_game():
	SaveManager.save_game(level.custom_seed, player, level.enemies.get_children(), level.coins.get_children(), player.collected_coin)

# сигнал на столкновение с врагом
func _on_player_dead():
	pause_menu.set_screen(pause_menu.SCREENTYPE.OVER)
	set_pause()
	
# сигнал на подбор всех монет
func _on_player_win():
	pause_menu.set_screen(pause_menu.SCREENTYPE.WIN)
	set_pause()
