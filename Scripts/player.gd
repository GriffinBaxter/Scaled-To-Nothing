extends CharacterBody2D

const SPEED = 200.0

@onready var area_2d_for_scaling: Area2D = $Area2DForScaling
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction:
		velocity.x = direction.x * SPEED
		velocity.y = direction.y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)


func _process(_delta: float) -> void:
	move_and_slide()

	scale = area_2d_for_scaling.scale / 4
	collision_shape_2d.scale = area_2d_for_scaling.scale / 4
