extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -300.0

func _physics_process(delta: float) -> void:
	# Tambahkan gravitasi
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Gerak otomatis ke kanan
	velocity.x = SPEED

	# Lompat jika tombol ditekan dan sedang di lantai
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()
