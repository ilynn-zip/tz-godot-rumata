extends CharacterBody2D
class_name Enemy

var speed : float			# скорость врага
var move_radius : float		# радиус в котором выбирается следующая цель движения
var avoid_strength : float	# радиус в ккотором избегаются формы столкновений

var target_position: Vector2 # следущая позицция - куда движится враг

@onready var path_timer: Timer = $PathTimer		# таймер для выбора следующий позиции
@onready var enemy_sprite: Sprite2D = $Enemy

func _ready() -> void:
	# загрузка параметров врага из конфига
	speed = Config.enemy_speed
	move_radius = Config.enemy_move_radius
	avoid_strength = Config.enemy_avoid_strenght
	path_timer.wait_time = Config.enemy_change_target_time
	choose_new_target()

func _process(delta: float) -> void:
	var direction = (target_position - global_position).normalized()
	var distance = global_position.distance_to(target_position)
	
	if direction.x <= 0:
		enemy_sprite.flip_h = true
	else:
		enemy_sprite.flip_h = false

	if distance > 1:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()
	
	# учёт столкновений
	# move&slide возвращает обрезанну скорость при коллизии
	# корректируем вектор направления
	# важно! здесь учитываются как стены так и сам игрок
	# в контексте игры, я решил, что это нормально и прикольно, 
	# когда враги-мыши немного избегают игрока
	# но при этом задеть врага можно, если прямо "налететь на него"
	if !is_equal_approx(velocity.length(), speed):
		target_position += velocity.normalized() * avoid_strength * speed

# функция выбора новой точки для передвижения
# выбор радномный
func choose_new_target() -> void:
	path_timer.start()
	var angle = randf() * TAU
	var radius = randf() * move_radius
	var offset = Vector2(cos(angle), sin(angle)) * radius
	target_position = global_position + offset

# сигнал таймера для выбора новой точки передвижения
func _on_path_timer_timeout() -> void:
	choose_new_target()
