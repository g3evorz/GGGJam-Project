extends CharacterBody2D

const SPEED = 250
var is_walking  = false
var target_position = Vector2.ZERO
var can_attack = false
var game_manager = null

@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	game_manager = get_parent()
	$AnimatedSprite2D.play("Idle")


func start_auto_walk(enemy_pos):
	is_walking =  true
	target_position = Vector2(enemy_pos.x - 100, global_position.y)
	$AnimatedSprite2D.play("Walk")
	
func _physics_process(delta: float) -> void:
	if is_walking:
		var direction = (target_position - global_position).normalized()
		var velocity = direction * SPEED * delta
		
		if global_position.distance_to(target_position) > 10:
			move_and_collide(velocity)
		else:
			is_walking =  false
			$AnimatedSprite2D.play("Idle")
			reach_enemy()
			
func reach_enemy():
	game_manager.player_reached_enemy()

func play_stand_off_animation():
	animated_sprite.play("Idle")

func play_attack_animation():
	animated_sprite.play("Attack")

func play_death_animation():
	animated_sprite.play("Death")
	
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate:a", 0.0, 0.5).set_delay(0.2)
	
func enable_attack_window():
	can_attack = true
	animated_sprite.play("Telegraph")
	animated_sprite.modulate = Color(1.2, 1.2, 1.0)  # Visual feedback

func disable_attack_window():
	can_attack = false
	animated_sprite.modulate = Color(1, 1, 1)
	
func _input(event):
	if is_walking:
		return
	else: 
		if event.is_action_pressed("Attack (Spacebar)"):
			attempt_attack()

func attempt_attack():
	if can_attack:
		game_manager.handle_successful_attack()
	else:
		game_manager.handle_failed_attack()
		
