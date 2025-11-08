extends Camera2D

enum CameraMode { FOLLOW_PLAYER, STANDOFF }

var current_mode = CameraMode.FOLLOW_PLAYER
var player: CharacterBody2D = null
var current_enemy: CharacterBody2D = null

@export var normal_zoom = Vector2(1.0, 1.0)  # Zoom normal (follow player)
@export var standoff_zoom = Vector2(1.3, 1.3)  # Zoom saat standoff (lebih dekat)

@export var follow_smooth_speed = 5.0  # Kecepatan smooth follow player
@export var standoff_smooth_speed = 3.0  # Kecepatan smooth ke standoff position
@export var zoom_smooth_speed = 4.0  # Kecepatan zoom transition

@export var follow_offset = Vector2(0, -20)  # Offset dari player saat follow
@export var standoff_offset = Vector2(0, -30)  # Offset dari midpoint saat standoff

# Target variables
var target_position = Vector2.ZERO
var target_zoom = Vector2(1.0, 1.0)

func _ready() -> void:
	# Cari player di scene
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")
	
	if not player:
		push_error("Player tidak ditemukan! Pastikan player ada di group 'player'")
		return
	
	# Set initial position
	global_position = player.global_position + follow_offset
	zoom = normal_zoom
	target_zoom = normal_zoom
	
	# Enable smoothing
	position_smoothing_enabled = true
	position_smoothing_speed = follow_smooth_speed
	
	print("Camera ready - Following player")

func _process(delta: float) -> void:
	if not player:
		return
	
	# Update target berdasarkan mode
	match current_mode:
		CameraMode.FOLLOW_PLAYER:
			_update_follow_mode()
		CameraMode.STANDOFF:
			_update_standoff_mode()
	
	# Smooth zoom transition
	zoom = zoom.lerp(target_zoom, zoom_smooth_speed * delta)

# Mode: Follow player normal
func _update_follow_mode():
	target_position = player.global_position + follow_offset
	global_position = global_position.lerp(target_position, follow_smooth_speed * get_process_delta_time())

# Mode: Standoff - fokus ke tengah antara player dan enemy
func _update_standoff_mode():
	if not current_enemy:
		# Fallback ke follow player jika enemy hilang
		_update_follow_mode()
		return
	
	# Hitung midpoint antara player dan enemy
	var midpoint = (player.global_position + current_enemy.global_position) / 2.0
	target_position = midpoint + standoff_offset
	
	# Smooth move ke target
	global_position = global_position.lerp(target_position, standoff_smooth_speed * get_process_delta_time())

# ========================================
# PUBLIC FUNCTIONS - Dipanggil dari game_manager
# ========================================

# Masuk mode standoff
func enter_standoff(enemy: CharacterBody2D):
	if not enemy:
		push_error("Enemy is null!")
		return
	
	current_mode = CameraMode.STANDOFF
	current_enemy = enemy
	target_zoom = standoff_zoom
	position_smoothing_speed = standoff_smooth_speed
	
	print("Camera: Entering standoff mode - zooming in")

# Keluar dari standoff, kembali follow player
func exit_standoff():
	current_mode = CameraMode.FOLLOW_PLAYER
	current_enemy = null
	target_zoom = normal_zoom
	position_smoothing_speed = follow_smooth_speed
	
	print("Camera: Exiting standoff mode - back to follow player")

# ========================================
# OPTIONAL: Camera Shake Effect
# ========================================

# Panggil untuk efek shake (misal saat attack berhasil/gagal)
func shake(intensity: float = 10.0, duration: float = 0.3):
	var original_offset = offset
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Shake loop
	var shake_count = int(duration / 0.05)
	for i in range(shake_count):
		var shake_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(self, "offset", shake_offset, 0.05)
	
	# Kembali ke posisi normal
	tween.tween_property(self, "offset", original_offset, 0.1)

# ========================================
# DEBUG VISUALIZATION
# ========================================

# Uncomment untuk visualisasi debug di editor
# func _draw():
# 	if current_mode == CameraMode.STANDOFF and current_enemy:
# 		# Draw line antara player dan enemy
# 		var player_screen_pos = to_local(player.global_position)
# 		var enemy_screen_pos = to_local(current_enemy.global_position)
# 		draw_line(player_screen_pos, enemy_screen_pos, Color(1, 0, 0, 0.5), 2.0)
# 		
# 		# Draw target position
# 		draw_circle(Vector2.ZERO, 10, Color(0, 1, 0, 0.5))
