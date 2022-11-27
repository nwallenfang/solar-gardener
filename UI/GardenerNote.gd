extends Control


func _on_DoneButton_pressed() -> void:
	Dialog.get_node("VoiceOver").stop()
	Game.get_node("SettingsOpenCooldown").start(0.4)
	Game.game_state = Game.State.INGAME

func set_text(text: String):
	$"%Text".text = text
