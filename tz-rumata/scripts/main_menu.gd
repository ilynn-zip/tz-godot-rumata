extends Control

@export var game_scene : PackedScene

@onready var continue_button: Button = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/ContinueButton
@onready var howtip: MarginContainer = $MarginContainer2

func _ready() -> void:
	# если найдено сохранение, то показываем кнопку продолжения игры
	if FileAccess.file_exists(SaveManager.SAVE_PATH):
		continue_button.show()
	else:
		continue_button.hide()

# нажати кнопки продолжить
func _on_continue_button_pressed() -> void:
	SaveManager.load_save = true
	get_tree().change_scene_to_packed(game_scene)
	
# нажати кнопки новой игры
func _on_start_button_pressed() -> void:
	SaveManager.load_save = false
	get_tree().change_scene_to_packed(game_scene)

# показать подсказку
func _on_how_button_pressed() -> void:
	howtip.show()

# нажати кнопки выход
func _on_exit_button_pressed() -> void:
	get_tree().quit()
	
# нажати кнопки назад из подсказки
func _on_back_button_pressed() -> void:
	howtip.hide()
