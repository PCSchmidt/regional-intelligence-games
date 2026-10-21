extends RefCounted

## Procedural geometry. Every mesh in this prototype is generated here from
## engine primitives and authored parameters, so the build bundles no third-party
## art assets.

const Seabed = preload("res://scripts/seabed.gd")


static func seabed_mesh(step: float = 1.0) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var extent := Seabed.HALF_EXTENT
	var count := int(round(extent * 2.0 / step))
	for ix in count:
		for iz in count:
			var x0 := -extent + ix * step
			var z0 := -extent + iz * step
			var x1 := x0 + step
			var z1 := z0 + step
			var p00 := Vector3(x0, Seabed.height_at(x0, z0), z0)
			var p10 := Vector3(x1, Seabed.height_at(x1, z0), z0)
			var p01 := Vector3(x0, Seabed.height_at(x0, z1), z1)
			var p11 := Vector3(x1, Seabed.height_at(x1, z1), z1)
			_add_triangle(surface, p00, p01, p10)
			_add_triangle(surface, p10, p01, p11)
	surface.generate_normals()
	return surface.commit()


static func _add_triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	if (b - a).cross(c - a).length_squared() < 0.00000001:
		return
	surface.add_vertex(a)
	surface.add_vertex(c)
	surface.add_vertex(b)


static func cable_mesh(sides: int = 8, step: float = 0.5) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var extent := Seabed.HALF_EXTENT
	var segments := int(round(extent * 2.0 / step))
	var rings := []
	for index in segments + 1:
		var x := -extent + index * step
		var centre := Vector3(x, Seabed.cable_y(x), 0.0)
		var ring := []
		for side in sides:
			var angle := TAU * float(side) / float(sides)
			ring.append(centre + Vector3(0.0, sin(angle), cos(angle)) * Seabed.CABLE_RADIUS)
		rings.append(ring)
	for index in segments:
		var current: Array = rings[index]
		var next: Array = rings[index + 1]
		for side in sides:
			var a: Vector3 = current[side]
			var b: Vector3 = current[(side + 1) % sides]
			var c: Vector3 = next[side]
			var d: Vector3 = next[(side + 1) % sides]
			_add_triangle(surface, a, c, b)
			_add_triangle(surface, b, c, d)
	surface.generate_normals()
	return surface.commit()


static func furrow_mesh(feature: Dictionary) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var centre := Seabed.feature_position(feature)
	var length := 14.0
	var half_width := 1.1
	var steps := 28
	for index in steps:
		var t0 := float(index) / float(steps)
		var t1 := float(index + 1) / float(steps)
		var z0 := centre.z - length * 0.5 + length * t0
		var z1 := centre.z - length * 0.5 + length * t1
		var x0 := centre.x + sin(t0 * PI) * 0.6
		var x1 := centre.x + sin(t1 * PI) * 0.6
		var left0 := Vector3(x0 - half_width, Seabed.height_at(x0 - half_width, z0) + 0.02, z0)
		var right0 := Vector3(x0 + half_width, Seabed.height_at(x0 + half_width, z0) + 0.02, z0)
		var left1 := Vector3(x1 - half_width, Seabed.height_at(x1 - half_width, z1) + 0.02, z1)
		var right1 := Vector3(x1 + half_width, Seabed.height_at(x1 + half_width, z1) + 0.02, z1)
		_add_triangle(surface, left0, left1, right0)
		_add_triangle(surface, right0, left1, right1)
	surface.generate_normals()
	return surface.commit()


static func slide_lobe_mesh(feature: Dictionary) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var centre := Seabed.feature_position(feature)
	var radius := float(feature.get("radius", 3.0)) * 2.2
	var rings := 10
	var sides := 20
	for ring in rings:
		var r0 := radius * float(ring) / float(rings)
		var r1 := radius * float(ring + 1) / float(rings)
		var h0 := 0.02
		var h1 := 0.02
		for side in sides:
			var a0 := TAU * float(side) / float(sides)
			var a1 := TAU * float(side + 1) / float(sides)
			var p00 := centre + Vector3(cos(a0) * r0, h0, sin(a0) * r0)
			var p01 := centre + Vector3(cos(a1) * r0, h0, sin(a1) * r0)
			var p10 := centre + Vector3(cos(a0) * r1, h1, sin(a0) * r1)
			var p11 := centre + Vector3(cos(a1) * r1, h1, sin(a1) * r1)
			p00.y = Seabed.height_at(p00.x, p00.z) + h0
			p01.y = Seabed.height_at(p01.x, p01.z) + h0
			p10.y = Seabed.height_at(p10.x, p10.z) + h1
			p11.y = Seabed.height_at(p11.x, p11.z) + h1
			_add_triangle(surface, p00, p01, p10)
			_add_triangle(surface, p01, p11, p10)
	surface.generate_normals()
	return surface.commit()


static func netting_mesh(feature: Dictionary) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var centre := Seabed.feature_position(feature)
	var span := 1.6
	var strands := 7
	for index in strands:
		var offset := -span * 0.5 + span * float(index) / float(strands - 1)
		var wobble := sin(float(index) * 1.7) * 0.18
		var a := centre + Vector3(offset, -0.35 + wobble, -0.5)
		var b := centre + Vector3(offset + 0.12, 0.45 + wobble, 0.5)
		_add_ribbon(surface, a, b, 0.035)
	for index in strands:
		var offset := -span * 0.5 + span * float(index) / float(strands - 1)
		var wobble := cos(float(index) * 1.3) * 0.16
		var a := centre + Vector3(-0.5, -0.3 + wobble, offset)
		var b := centre + Vector3(0.5, 0.4 + wobble, offset + 0.1)
		_add_ribbon(surface, a, b, 0.035)
	surface.generate_normals()
	return surface.commit()


static func _add_ribbon(surface: SurfaceTool, a: Vector3, b: Vector3, width: float) -> void:
	var direction := (b - a).normalized()
	var side := direction.cross(Vector3.UP).normalized() * width
	_add_triangle(surface, a - side, b - side, a + side)
	_add_triangle(surface, a + side, b - side, b + side)


static func abrasion_mesh(feature: Dictionary) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var centre := Seabed.feature_position(feature)
	var length := 5.0
	var steps := 20
	for index in steps:
		var t0 := float(index) / float(steps)
		var t1 := float(index + 1) / float(steps)
		var x0 := centre.x - length * 0.5 + length * t0
		var x1 := centre.x - length * 0.5 + length * t1
		var y0 := Seabed.cable_y(x0) + Seabed.CABLE_RADIUS * 0.9
		var y1 := Seabed.cable_y(x1) + Seabed.CABLE_RADIUS * 0.9
		var w := 0.05
		_add_triangle(surface, Vector3(x0, y0, -w), Vector3(x0, y0, w), Vector3(x1, y1, -w))
		_add_triangle(surface, Vector3(x0, y0, w), Vector3(x1, y1, w), Vector3(x1, y1, -w))
	surface.generate_normals()
	return surface.commit()
