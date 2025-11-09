extends Node2D

enum GameState { APPROACH, STAND_OFF, TIMING_WINDOW, RESULT, GAME_OVER }
# kelola state buat playernya
var current_state = GameState.APPROACH
var current_enemy = null
var enemies = []
var current_enemy_index = 0

@onready var player = $Player
@onready var camera = $Camera2D
@onready var standoff_timer = $StandOffTimer
@onready var timing_timer = $TimingWindowTimer
@onready var result_timer = $ResultTimer
@onready var cinematic_bars = $CinematicBars
@onready var pause_menu = $PauseMenu


const STANDOFF_DURATION := 2.0
const TIMING_WINDOW_DURATION := 0.3
const RESULT_DELAY := 0.7

func _ready() -> void:

	standoff_timer.timeout.connect(_on_stand_off_timer_timeout)
	timing_timer.timeout.connect(_on_timing_window_timer_timeout)
	result_timer.timeout.connect(_on_result_timer_timeout)
	pause_menu.hide()
	
	setup_enemies()
	start_approach()

func setup_enemies():
	enemies = get_tree().get_nodes_in_group("enemies") #masukan ke array musuh
	
	if enemies.size() > 0:
		current_enemy = enemies[current_enemy_index] #


	enemies = get_tree().get_nodes_in_group("enemies")
	
	if enemies.size() > 0:
		current_enemy = enemies[current_enemy_index]
		print("Total enemies: ", enemies.size())
	else:
		push_error("No enemies found in group 'enemies'!")

func start_approach():
	current_state = GameState.APPROACH
	if current_enemy:
		player.start_auto_walk(current_enemy.global_position)
		print("Starting approach to enemy ", current_enemy_index + 1)

# Dipanggil dari player ketika sampai di posisi enemy
func player_reached_enemy():
	if current_state != GameState.APPROACH:
		return
		
	current_state = GameState.STAND_OFF
	print("Player reached enemy - Starting stand off")
	start_stand_off()

func start_stand_off():
	# Animasi stand off untuk player dan enemy
	player.play_stand_off_animation()
	if current_enemy:
		current_enemy.play_stand_off_animation()
	
	
	camera.enter_standoff(current_enemy)
	cinematic_bars.show_bars()
	standoff_timer.start(STANDOFF_DURATION)

# Timer stand off selesai - enemy mulai telegraph
func _on_stand_off_timer_timeout():
	if current_state != GameState.STAND_OFF:
		return
		
	print("Stand off complete - Enemy telegraphing attack")
	if current_enemy:
		current_enemy.show_telegraph()

# Dipanggil dari enemy setelah telegraph selesai
func start_timing_window():
	current_state = GameState.TIMING_WINDOW
	print("TIMING WINDOW STARTED - Player can attack now!")
	
	# Beritahu player bahwa window terbuka
	player.enable_attack_window()
	
	# Start timer untuk timeout window
	timing_timer.start(TIMING_WINDOW_DURATION)

# Window timeout - player terlambat atau tidak attack
func _on_timing_window_timer_timeout():
	if current_state != GameState.TIMING_WINDOW:
		return
		
	player.disable_attack_window()
	handle_failed_attack()

# Dipanggil dari player ketika berhasil attack dalam window
func handle_successful_attack():
	if current_state != GameState.TIMING_WINDOW:
		return
		
	# Stop timing timer
	timing_timer.stop()
	player.disable_attack_window()
	
	current_state = GameState.RESULT
	print("SUCCESS! Player attacked in time")
	
	
	# Animasi attack sukses
	player.play_attack_animation()
	if current_enemy:
		current_enemy.play_defeated_animation()
		
	if camera and camera.has_method("shake"):
		print("→ Camera shake (success)")
		await get_tree().create_timer(0.3).timeout
		camera.shake(8.0, 0.2)
	
	# Tunggu sebentar sebelum lanjut
	result_timer.start(RESULT_DELAY)

# Dipanggil dari player ketika attack di luar window
func handle_failed_attack():
	if current_state == GameState.GAME_OVER:
		return
		
	current_state = GameState.GAME_OVER
	print("FAILED! Wrong timing - Game Over")
	
	if camera and camera.has_method("shake"):
		print("→ Camera shake (fail)")
		await get_tree().create_timer(0.15).timeout
		camera.shake(15.0, 0.4)
		
	# Animasi game over
	player.play_death_animation()
	if current_enemy:
		current_enemy.play_attack_animation()
	
	# Tunggu sebentar lalu restart
	await get_tree().create_timer(2.0).timeout
	restart_game()


func _on_result_timer_timeout():
	if current_state != GameState.RESULT:
		return
		
	if camera and camera.has_method("exit_standoff"):
		print("→ Calling camera.exit_standoff()")
		cinematic_bars.hide_bars()
		camera.exit_standoff()
		
	current_enemy_index += 1
	
	if current_enemy_index < enemies.size():
		current_enemy = enemies[current_enemy_index]
		print("Moving to next enemy: ", current_enemy_index + 1, "/", enemies.size())
		start_approach()
	else:	
		stage_complete()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		if get_tree().paused:
			resume_game()
		else:
			pause_game()

func pause_game():
	pause_menu.show()
	get_tree().paused = true
	

func resume_game():
	pause_menu.hide()
	get_tree().paused = false
	
	

func stage_complete():
	current_state = GameState.GAME_OVER  # Reuse state untuk stage complete
	
	# Tunggu sebentar lalu next stage/restart
	await get_tree().create_timer(3.0).timeout

func next_stage():
	await get_tree().create_timer(3.0).timeout
	

func restart_game():
	get_tree().reload_current_scene()


func _on_resume_pressed() -> void:
	get_tree().paused = false
	resume_game()
	
	
func _on_home_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/Homescreen.tscn")
	

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scene/Main_scene.tscn")
