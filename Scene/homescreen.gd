extends Control

@onready var main_button: VBoxContainer = $"MarginContainer/Main button"
@onready var setting: Panel = $Setting

func _ready():
	main_button.visible = true
	setting.visible = false

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/Main_scene.tscn")


func _on_setting_pressed() -> void:
	print("Setting pressed")
	main_button.visible = false
	setting.visible = true


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_back_setting_pressed() -> void:
	_ready()
