extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0

func _physics_process(delta: float) -> void:
	# Tambahkan gravitasi
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Gerak otomatis ke kanan
	velocity.x = SPEED

	move_and_slide()
