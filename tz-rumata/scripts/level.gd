extends Node2D

@export var noise_texture : NoiseTexture2D
@export var coin_scene : PackedScene
@export var enemy_scene : PackedScene

var custom_seed : int	# кастомный сид генерации
var threshold: float	# граница - где стены, где пол
var width : int			# ширина карты в тайлах
var height : int		# высота карты в тайлах
var scale_map : float	# коэффициент масштабирования шума

var coin_count : int	# кол-во монет для спавна
var min_coin_spawn_distance : int	# минимально расстояние спавно от игрока

var enemy_count : int	# кол-во врагов для спавна
var min_enemy_spawn_distance : int	# минимальное расстояние для спавна от игрока

# шум
# использовал встроенный фастнойз с типом value
# решил, что такое больше подойдет для "подземелья"
var noise : Noise
var ground : = Vector2i(1, 1)	# тайл пола из тайлсета, нужен для генерации
var walls : Array[Vector2i] = [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3)]	# тайлы внутренних стена для рандома
var ground_array : Array[Vector2i]	# массив пола для автотайлинга
var map: Array = []	# матрица всей карты, нужна для отрисовки

@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var coins: Node2D = $Coins
@onready var enemies: Node2D = $Enemies
@onready var player: Player = $"../Player"

func _ready() -> void:
	# загрузка параметров из конфига
	threshold = Config.threshold
	width = Config.width
	height = Config.height
	scale_map = Config.scale_map
	coin_count = Config.coins
	min_coin_spawn_distance = Config.min_coin_spawn_distance
	enemy_count = Config.enemies
	min_enemy_spawn_distance = Config.min_enemy_spawn_distance
	
	# если не загружаем сохранение, то берем сид или из конфига, или генерируем его
	if not SaveManager.load_save:
		custom_seed = Config.custom_seed
		if custom_seed == 0:
			custom_seed = randi()
			seed(custom_seed)
	
		# генерируем карту
		# получаем позицию всех тайлов пола для размещения играка, врагов и монет
		var floor_tiles : Array = generate_dungeon()
		var player_pos : Vector2i = spawn_player(floor_tiles)
		spawner("coin", player_pos, floor_tiles)
		spawner("enemy", player_pos, floor_tiles)

# функция генерации карты
func generate_dungeon() -> Array:
	if not tile_map_layer or not noise_texture:
		push_error("TileMapLyaer или Noise не назначены")
		return []
	
	# устанавливаем катом сид для повторения или генерации новой карты
	noise_texture.noise.seed = custom_seed
	noise = noise_texture.noise
	
	# заполние матрица карты бинарными значениями - пол true, стены false
	map.resize(height)
	for y in height:
		map[y] = []
		for x in width:
			var val = noise.get_noise_2d(x * scale_map, y * scale_map)
			map[y].append(val > threshold)
	
	# отрисоввка карты
	for y in height:
		for x in width:
			if map[y][x]:
				tile_map_layer.set_cell(Vector2i(x, y), 0, ground)
				ground_array.append(Vector2i(x, y))
			else:
				tile_map_layer.set_cell(Vector2i(x, y), 0, walls[randi_range(0, 2)])
			
	# выполняем автотайлинг
	tile_map_layer.set_cells_terrain_connect(ground_array, 0, 0, false)
	
	# после автотайлинга некоторые тайлы заменились на стены в радиусе одного тайла
	# поэтому нужно обновить map
	var floor_tiles = []
	for y in height:
		for x in width:
			if tile_map_layer.get_cell_atlas_coords(Vector2i(x, y)) == ground:
				map[y][x] = true
				floor_tiles.append(Vector2i(x, y))
			else:
				map[y][x] = false
	
	return floor_tiles

# спавн игрока в случайном месте на полу
func spawn_player(floor_tiles : Array) -> Vector2i:
	var pos : Vector2i = floor_tiles[randi() % floor_tiles.size()]
	player.global_position = tile_map_layer.map_to_local(pos)
	return pos

# спавн врагов и монет
func spawner(item_name : String, spawn_pos: Vector2i, floor_tiles : Array) -> void:
	var scene : PackedScene
	var counter : int
	var spawn_distance : int
	var contain : Node2D
	
	# установка значений для спавна
	if item_name == "coin":
		if not coin_scene:
			push_error("Не назначена Coin")
			return
		scene = coin_scene
		counter = coin_count
		spawn_distance = min_coin_spawn_distance
		contain = coins
	elif item_name == "enemy":
		if not enemy_scene:
			push_error("Не назначена Enemy")
			return
		scene = enemy_scene
		counter = enemy_count
		spawn_distance = min_enemy_spawn_distance
		contain = enemies
	else:
		print("Не найдено спавнов")
		return

	if floor_tiles.size() == 0:
		push_error("Нет пола для спавна")
		return

	while counter > 0:
		var pos = floor_tiles[randi() % floor_tiles.size()]
		# проверяем расстояние от игрока
		if pos.distance_to(spawn_pos) >= spawn_distance:
			var item = scene.instantiate()
			item.global_position = tile_map_layer.map_to_local(pos)
			contain.add_child(item)
			counter -= 1
