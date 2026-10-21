extends RefCounted

## Deterministic ROV flight model. Pure integration so a fixed input sequence
## produces identical results in tests and in the rendered scene.

const Seabed = preload("res://scripts/seabed.gd")

const MASS := 165.0
const THRUST := 900.0
const STRAFE_FACTOR := 0.7
const VERTICAL_THRUST := 700.0
const DRAG := 260.0
const MAX_SPEED := 1.6
const MAX_VERTICAL_SPEED := 0.9
const YAW_RATE := 1.1


static func forward_vector(yaw: float) -> Vector3:
	return Vector3(-sin(yaw), 0.0, -cos(yaw))


static func right_vector(yaw: float) -> Vector3:
	return Vector3(cos(yaw), 0.0, -sin(yaw))


static func step(position: Vector3, velocity: Vector3, yaw: float, input: Dictionary, delta: float) -> Dictionary:
	var forward := forward_vector(yaw)
	var right := right_vector(yaw)
	var thrust := forward * float(input.get("forward", 0.0)) * THRUST
	thrust += right * float(input.get("strafe", 0.0)) * THRUST * STRAFE_FACTOR
	thrust += Vector3.UP * float(input.get("vertical", 0.0)) * VERTICAL_THRUST

	var acceleration := thrust / MASS
	var next_velocity := velocity + acceleration * delta
	next_velocity *= exp(-DRAG / MASS * delta)

	var horizontal := Vector2(next_velocity.x, next_velocity.z)
	if horizontal.length() > MAX_SPEED:
		horizontal = horizontal.normalized() * MAX_SPEED
		next_velocity.x = horizontal.x
		next_velocity.z = horizontal.y
	next_velocity.y = clampf(next_velocity.y, -MAX_VERTICAL_SPEED, MAX_VERTICAL_SPEED)

	var next_yaw := wrapf(yaw + float(input.get("yaw", 0.0)) * YAW_RATE * delta, -PI, PI)
	var next_position := position + next_velocity * delta

	var bounded := Seabed.clamp_to_bounds(next_position)
	var clamped_x := not is_equal_approx(bounded.x, next_position.x)
	var clamped_z := not is_equal_approx(bounded.z, next_position.z)
	var clamped_y := not is_equal_approx(bounded.y, next_position.y)
	if clamped_x:
		next_velocity.x = 0.0
	if clamped_z:
		next_velocity.z = 0.0
	if clamped_y:
		next_velocity.y = 0.0

	return {
		"position": bounded,
		"velocity": next_velocity,
		"yaw": next_yaw,
		"clamped": clamped_x or clamped_z or clamped_y
	}


static func heading_degrees(yaw: float) -> float:
	return fposmod(rad_to_deg(-yaw), 360.0)
