extends Node

@onready var bgm_player = $AudioStreamPlayer2D

func _ready():
	if not bgm_player.playing:
		bgm_player.play()
