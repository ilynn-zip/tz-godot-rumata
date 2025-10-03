extends Node2D
class_name Coin

@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D

# удаляем монетку при сборе игроком
func disappear():
	audio.play()
	var tween : = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(0, 0), 0.3)
	await audio.finished
	queue_free()
