extends Control

# экран паузы, смерти и победы фактически одно и то же
# менятется только заголовок и видимость некоторых кнопок
# поэтому удобно иметь типы для определения что показывать
enum SCREENTYPE {PAUSE, WIN, OVER}
var type : SCREENTYPE = SCREENTYPE.PAUSE

@onready var label : Label = $MarginContainer/VBoxContainer/Label
@onready var resume_button : Button = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/ResumeButton
@onready var again_button : Button = $MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/AgainButton

func _ready() -> void:
	set_screen(type)

# установка типа экрана паузы
# в соответсвии с чем меняется заголовок "пауза", "смерть", "победа"
# и вимость кнопок "продолжить" и "начать заново" 
func set_screen(screen : SCREENTYPE = SCREENTYPE.PAUSE):
	type = screen
	match screen:
		SCREENTYPE.PAUSE:
			label.text = "Пауза"
			resume_button.show()
			again_button.hide()
		SCREENTYPE.WIN:
			label.text = "Всё собрал"
			resume_button.hide()
			again_button.show()
		SCREENTYPE.OVER:
			label.text = "Помер"
			resume_button.hide()
			again_button.show()
		_:
			pass

# автоматическое сохранение при выходе в меню или на рабочий стол
func _save_game():
	if type == SCREENTYPE.PAUSE:
		get_parent().get_parent().save_game()

# продолжить
func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	self.hide()

# начать заново
func _on_again_button_pressed() -> void:
	get_tree().reload_current_scene()

# выход в главное меню
func _on_main_menu_button_pressed() -> void:
	_save_game()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

# выход на рабочий стол
func _on_exit_button_pressed() -> void:
	_save_game()
	get_tree().quit()
