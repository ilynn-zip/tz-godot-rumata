extends CharacterBody2D
class_name Player
signal player_dead			# кастомный сигнал смерти игрока
signal player_win			# кастомный сигнал победы

# параметры загружаемые из конфиг файла
var max_speed : float		# максимальная скорость передвижения
var turn_speed : float		# скорость поворота игрока
var acceleration : float	# ускорение, для плавного перемещения
var dash_speed : float		# скорость дэша

# флаги состояний
var moving : bool = false	# движемся или нет, нужно для звука в основном
var is_dashing : bool = false	# дэшимся
var can_dash : bool = true	# можно ли использовать дэш

var current_speed : float = 0.0	# текущая скорость

var collected_coin : int = 0	# счётчик монет

@onready var dash_timer : Timer = $DashTimers/DashTime	# таймер активации дэша
@onready var cd_time : Timer = $DashTimers/CDTime	#таймер кулдауна дэша
@onready var camera: Camera2D = $Camera2D

@onready var gui: Control = $CanvasLayer/GUI

@onready var move_audio: AudioStreamPlayer2D = $MoveAudio	# звук передвижения
@onready var death_audio: AudioStreamPlayer2D = $DeathAudio	# звук смерти

func _ready() -> void:
	# загрузка параметров из конфиг файла
	max_speed = Config.player_max_speed
	turn_speed = Config.player_turn_speed
	acceleration = Config.player_acceleration
	dash_speed = Config.player_dash_speed
	dash_timer.wait_time = Config.player_dash_time
	cd_time.wait_time = Config.player_dash_cooldown
	
	# обновляем свидимый счётчик
	update_coins()

func _physics_process(delta: float) -> void:
	# высчитываем ветор направления и скорость
	var input_dir : = Input.get_vector("left", "right", "forward", "back")
	var target_speed : float = -input_dir.y * max_speed
	rotation += deg_to_rad(input_dir.x * turn_speed * delta)
	
	# двигаем игрока по напраления
	if abs(target_speed) > 0.1:
		# тут как раз включаем звук именно во время движения
		if not moving:
			moving = true
			move_audio.set("parameters/switch_to_clip", "Vc Start")
			move_audio.play()
			move_audio.set("parameters/switch_to_clip", "Vc Mid")
		current_speed = move_toward(current_speed, target_speed, acceleration * delta)
	else:
		if moving:
			moving = false
			move_audio.set("parameters/switch_to_clip", "Vc Stop")
			#move_audio.play()
		current_speed = move_toward(current_speed, 0, acceleration * delta)

	var forward_vector: Vector2 = Vector2.UP.rotated(rotation)
	# если нажали дэш
	if is_dashing:
		velocity = forward_vector * dash_speed
	else:
		velocity = forward_vector * current_speed

	move_and_slide()

func _input(event: InputEvent) -> void:
	# если нажали дэш, запускаем все таймеры и меняем флаги состояний
	if event.is_action_pressed("dash") and can_dash:
		is_dashing = true
		can_dash = false
		dash_timer.start()
		cd_time.start()

# обновление видимого счётчика
func update_coins():
	gui.update_current(collected_coin)
	
	# если достигнуто необходимое кол-во монет, ты вызываем сигнал победы
	if collected_coin == int(gui.total.text):
		player_win.emit()

# сигнал таймаута таймера дэша
func _on_dash_time_timeout() -> void:
	is_dashing = false

# сигнал таймаута таймера кулдауна
func _on_cd_time_timeout() -> void:
	can_dash = true

# проверка на коллизию с врагом
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Enemy:
		death_audio.play()
		player_dead.emit()

# проверка на коллизию с монеткой
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Coin:
		area.get_parent().disappear()
		collected_coin += 1
		update_coins()
		
