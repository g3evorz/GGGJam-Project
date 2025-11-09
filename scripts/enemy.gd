extends CharacterBody2D

# Variabel state
var is_telegraphing = false
var game_manager = null

# Referensi node
@onready var animated_sprite = $AnimatedSprite2D
@onready var telegraph_timer = $TelegraphTimer

# Konstanta
const TELEGRAPH_DURATION = 0.25  # Durasi visual telegraph (dalam detik)

func _ready() -> void:
	
	# Connect signal telegraph timer
	if telegraph_timer:
		telegraph_timer.timeout.connect(_on_telegraph_timer_timeout)
	
	game_manager = get_parent()
	# Play idle animation
	if animated_sprite:
		animated_sprite.play("Idle")


func play_stand_off_animation():
	if animated_sprite:
		# Bisa gunakan animasi khusus "Ready" atau "StandOff"
		# Jika tidak ada, pakai "Idle"
		if animated_sprite.sprite_frames.has_animation("Ready"):
			animated_sprite.play("Idle")

# Dipanggil saat enemy dikalahkan
func play_defeated_animation():
	if not animated_sprite:
		return
	
	animated_sprite.play("Death")
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate:a", 0.0, 0.5).set_delay(0.2)
	
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	

	await get_tree().create_timer(0.7).timeout
	queue_free()

func play_attack_animation():
	animated_sprite.play("Attack")


# ========================================
# TELEGRAPH LOGIC (CUE UNTUK PLAYER)
# ========================================

# Dipanggil oleh game_manager untuk mulai telegraph
func show_telegraph():
	is_telegraphing = true
	
	# === VISUAL EFFECT 1: Scale Pop ===
	
	if animated_sprite:
		animated_sprite.play("Telegraph")
		var tween_flash = create_tween()
		tween_flash.set_parallel(true)
		
		# Terang
		tween_flash.tween_property(animated_sprite, "modulate", Color(2.0, 2.0, 2.0), 0.1)
		# Normal
		tween_flash.tween_property(animated_sprite, "modulate", Color(1.0, 1.0, 1.0), 0.1).set_delay(0.1)
	

	

	# === AUDIO CUE ===
	# Jika ada AudioStreamPlayer untuk sound effect
	if has_node("TelegraphSound"):
		var sfx = get_node("TelegraphSound")
		if sfx and sfx is AudioStreamPlayer2D:
			sfx.play()
	
	# Play animasi telegraph khusus jika ada
	if animated_sprite and animated_sprite.sprite_frames.has_animation("Telegraph"):
		animated_sprite.play("Telegraph")
	
	# Start timer untuk durasi telegraph
	if telegraph_timer:
		telegraph_timer.start(TELEGRAPH_DURATION)
	else:
		# Fallback jika timer tidak ada
		await get_tree().create_timer(TELEGRAPH_DURATION).timeout
		_on_telegraph_timer_timeout()

# ========================================
# TIMER CALLBACK
# ========================================

# Dipanggil ketika telegraph timer selesai
func _on_telegraph_timer_timeout():
	is_telegraphing = false
	print(name, " telegraph complete - opening timing window")
	
	# Beritahu game manager untuk membuka timing window
	if game_manager and game_manager.has_method("start_timing_window"):
		game_manager.start_timing_window()
	else:
		push_error("Game manager tidak ditemukan atau tidak punya method start_timing_window!")

# ========================================
# OPTIONAL: DEBUG VISUALIZATION
# ========================================

# Uncomment untuk debug visual di editor
# func _draw():
# 	# Draw circle untuk visualisasi telegraph
# 	if is_telegraphing:
# 		draw_circle(Vector2.ZERO, 50, Color(1, 0, 0, 0.3))
