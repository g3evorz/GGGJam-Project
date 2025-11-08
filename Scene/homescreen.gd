extends Control




func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/Main_scene.tscn")


func _on_setting_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/option.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
