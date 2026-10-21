extends RefCounted

## Single source of truth for seabed and cable geometry. Pure functions only so
## the domain tests and the rendered scene agree exactly.

const BASE_DEPTH := -420.0
const HALF_EXTENT := 35.0
const MIN_ALTITUDE := 0.8
const MAX_ALTITUDE := 30.0
const SPAN_HALF_LENGTH := 6.0
const SPAN_LIFT := 1.4
const CABLE_RADIUS := 0.045


static func height_at(x: float, z: float) -> float:
	var base := BASE_DEPTH - 0.05 * z + 2.2 * sin(x * 0.11) * cos(z * 0.09) + 0.9 * sin((x + z) * 0.21)
	var channel_center := -18.0 + sin(clampf((z - 5.0) / 14.0, 0, 1) * PI) * 0.6
	var channel := 0.55 * exp(-pow((x - channel_center) / 1.1, 2.0)) * smoothstep(4.0, 6.0, z) * (1.0 - smoothstep(18.0, 20.0, z))
	var lobe := 0.9 * maxf(0, 1.0 - (pow(x - 16.0, 2) + pow(z + 14.0, 2)) / pow(6.6, 2))
	return base - channel + lobe


static func cable_y(x: float) -> float:
	var base := height_at(x, 0.0) + CABLE_RADIUS
	if absf(x) <= SPAN_HALF_LENGTH:
		var t := absf(x) / SPAN_HALF_LENGTH
		return base + SPAN_LIFT * (1.0 - t * t)
	return base


static func feature_position(feature: Dictionary) -> Vector3:
	var x := float(feature.get("x", 0.0))
	var z := float(feature.get("z", 0.0))
	var lift := float(feature.get("lift", 0.0))
	var y := cable_y(x) if bool(feature.get("on_cable", false)) else height_at(x, z)
	return Vector3(x, y + lift, z)


static func altitude_at(position: Vector3) -> float:
	return position.y - height_at(position.x, position.z)


static func clamp_to_bounds(position: Vector3) -> Vector3:
	var clamped := position
	clamped.x = clampf(clamped.x, -HALF_EXTENT, HALF_EXTENT)
	clamped.z = clampf(clamped.z, -HALF_EXTENT, HALF_EXTENT)
	var floor_y := height_at(clamped.x, clamped.z) + MIN_ALTITUDE
	var ceiling_y := height_at(clamped.x, clamped.z) + MAX_ALTITUDE
	clamped.y = clampf(clamped.y, floor_y, ceiling_y)
	return clamped


static func is_inside_bounds(position: Vector3) -> bool:
	if absf(position.x) > HALF_EXTENT or absf(position.z) > HALF_EXTENT:
		return false
	var altitude := altitude_at(position)
	return altitude >= MIN_ALTITUDE - 0.001 and altitude <= MAX_ALTITUDE + 0.001


static func cable_distance(position: Vector3) -> float:
	var nearest := Vector3(position.x, cable_y(position.x), 0.0)
	return position.distance_to(nearest)
