extends Control

@onready var current: Label = $MarginContainer/HBoxContainer/Current
@onready var total: Label = $MarginContainer/HBoxContainer/Total

# тут ничего интересного просто обновление лейблов
func _ready() -> void:
	total.text = str(Config.coins)

func update_current(num : int):
	current.text = str(num)
