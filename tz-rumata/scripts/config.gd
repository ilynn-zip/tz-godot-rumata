extends Node

# переменные настройи игрока
var player_max_speed : float			# максимальная скорость
var player_turn_speed : float   		# скорость поворота
var player_acceleration : float			# ускорение для плавного набора скорости
var player_dash_speed : float			# скорость дэша
var player_dash_time : float			# время дэша
var player_dash_cooldown : float		# откат дэша

# переменные настройки врагов
var enemy_speed : float					# скорость врагов
var enemy_move_radius : float			# радиус выбора новой позиции
var enemy_avoid_strenght : float		# избегие столкновений
var enemy_change_target_time : float	# таймер выборы новой точки

# переменные настройки карты
var custom_seed : int					# кастомный сид для генерации
var width : int							# ширина карты в тайлах
var height : int						# высота карты в тайлах
var threshold : float					# граница разделения пола и стен
var scale_map : float					# масштабирование шума
var coins : int							# кол-во монет для спавна
var min_coin_spawn_distance  : int		# минимальная дистания спавна монет от игрока
var enemies : int						# кол-во врагов для спавна
var min_enemy_spawn_distance : int		# минимальная дистанция для спавна врагов от игрока

func _ready() -> void:
	load_config()

# загрузка файла настроек
func load_config() -> void:
	var cfg = ConfigFile.new()
	var err = cfg.load("res://config.cfg")
	if err != OK:
		push_error("Не удалось загрузить config.cfg")
		return

	# чтение и получение всех данных настроек
	player_max_speed = cfg.get_value("Player", "max_speed", 60)
	player_turn_speed = cfg.get_value("Player", "turn_speed", 180)
	player_acceleration = cfg.get_value("Player", "acceleration", 600)
	player_dash_speed = cfg.get_value("Player", "dash_speed", 100)
	player_dash_time = cfg.get_value("Player", "dash_time", 0.15)
	player_dash_cooldown = cfg.get_value("Player", "dash_cooldown", 0.4)

	enemy_speed = cfg.get_value("Enemy", "speed", 50)
	enemy_move_radius = cfg.get_value("Enemy", "move_radius", 100.0)
	enemy_avoid_strenght = cfg.get_value("Enemy", "avoid_strenght", 0.5)
	enemy_change_target_time = cfg.get_value("Enemy", "change_target_time", 2.0)

	custom_seed = cfg.get_value("Level", "custom_seed", 0)
	width = cfg.get_value("Level", "width", 80)
	height = cfg.get_value("Level", "height", 80)
	threshold = cfg.get_value("Level", "threshold", 0.0)
	scale_map = cfg.get_value("Level", "scale_map", 3.0)
	coins = cfg.get_value("Level", "coins", 20)
	min_coin_spawn_distance = cfg.get_value("Level", "min_coin_spawn_distance", 5)
	enemies = cfg.get_value("Level", "enemies", 10)
	min_enemy_spawn_distance = cfg.get_value("Level", "min_enemy_spawn_distance", 5)
	
