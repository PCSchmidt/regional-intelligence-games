extends RefCounted

const Geo = preload("res://scripts/geometry.gd")
const Seabed = preload("res://scripts/seabed.gd")


static func material(color: Color, metal: float = 0.0, roughness: float = 0.8) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.metallic = metal
	result.roughness = roughness
	return result


static func mesh(parent: Node3D, shape: Mesh, surface: Material, point: Vector3) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.mesh = shape
	node.material_override = surface
	node.position = point
	parent.add_child(node)
	return node


static func box(parent: Node3D, size: Vector3, point: Vector3, surface: Material) -> MeshInstance3D:
	var shape := BoxMesh.new()
	shape.size = size
	return mesh(parent, shape, surface, point)


static func beam(parent: Node3D, a: Vector3, b: Vector3, radius: float, surface: Material) -> MeshInstance3D:
	var shape := CylinderMesh.new()
	shape.top_radius = radius
	shape.bottom_radius = radius
	shape.height = a.distance_to(b)
	shape.radial_segments = 8
	var node := mesh(parent, shape, surface, (a + b) * 0.5)
	var direction := (b - a).normalized()
	node.quaternion = Quaternion(Vector3.UP, direction)
	return node


static func text(parent: Node3D, value: String, point: Vector3, size: int = 48) -> void:
	var label := Label3D.new()
	label.text = value
	label.font_size = size
	label.pixel_size = 0.005
	label.position = point
	label.modulate = Color("#c9eee5")
	parent.add_child(label)


static func build_deck(parent: Node3D) -> void:
	var steel := material(Color("#334650"), 0.7, 0.45)
	var yellow := material(Color("#d3a32e"), 0.35)
	var dark := material(Color("#18262c"), 0.4)
	var white := material(Color("#aebdbb"), 0.5)
	box(parent, Vector3(22, 0.4, 14), Vector3(0, -0.2, 3), steel)
	box(parent, Vector3(22, 3.5, 1), Vector3(0, 1.6, -4.5), white)
	box(parent, Vector3(4.8, 3.5, 0.1), Vector3(5.5, 1.6, -3.94), dark)
	text(parent, "SURVEY 01  /  BASHI CHANNEL", Vector3(0, 2.8, -3.9))
	text(parent, "FICTIONAL INCIDENT  -  AFT DECK", Vector3(0, 2.35, -3.88), 28)
	for x in [-10.5, 10.5]:
		for z in range(-3, 10, 2):
			beam(parent, Vector3(x, 0, z), Vector3(x, 1.1, z), 0.035, white)
		for y in [0.55, 1.1]:
			beam(parent, Vector3(x, y, -3), Vector3(x, y, 9.5), 0.035, white)
	for x in range(-10, 11, 2):
		beam(parent, Vector3(x, 0, 9.5), Vector3(x, 1.1, 9.5), 0.035, white)
	beam(parent, Vector3(-10.5, 1.1, 9.5), Vector3(10.5, 1.1, 9.5), 0.035, white)
	for x in [-3.3, 3.3]:
		box(parent, Vector3(0.45, 5.5, 0.45), Vector3(x, 2.75, -0.8), yellow)
		beam(parent, Vector3(x, 0.2, 2), Vector3(x, 5.4, -0.8), 0.11, steel)
	box(parent, Vector3(7.1, 0.5, 0.5), Vector3(0, 5.4, -0.8), yellow)
	beam(parent, Vector3(0, 5.3, -0.8), Vector3(0, 2.1, -0.8), 0.025, dark)
	rov_model(parent, Vector3(-5.4, 0.3, 1.5))
	box(parent, Vector3(2.0, 1.05, 0.8), Vector3(0, 0.55, 0), dark)
	var screen := material(Color("#133a39"))
	screen.emission_enabled = true
	screen.emission = Color("#3ee0c1")
	screen.emission_energy_multiplier = 0.7
	var display := box(parent, Vector3(1.75, 0.75, 0.08), Vector3(0, 1.55, -0.2), screen)
	display.rotation.x = -0.1
	text(parent, "ROV CONTROL\nE  /  CONSOLE", Vector3(0, 1.55, -0.14), 28)
	for x in [-8.5, 8.5]:
		var light := OmniLight3D.new()
		light.position = Vector3(x, 4.1, 1)
		light.light_color = Color("#ffd9a0")
		light.light_energy = 4.0
		light.omni_range = 17
		parent.add_child(light)
		box(parent, Vector3(0.7, 0.15, 0.4), Vector3(x, 4.2, 1), yellow)
	for z in range(-2, 9, 2):
		box(parent, Vector3(0.045, 0.012, 0.7), Vector3(-2, 0.014, z), yellow)
	var ocean := material(Color("#0b1c28"), 0.65, 0.2)
	box(parent, Vector3(600, 0.1, 600), Vector3(0, -2, 0), ocean)


static func rov_model(parent: Node3D, point: Vector3) -> void:
	var rov := Node3D.new()
	rov.position = point
	parent.add_child(rov)
	var frame := material(Color("#d9b52d"), 0.5)
	var black := material(Color("#151f25"), 0.4)
	box(rov, Vector3(1.8, 0.5, 3.1), Vector3(0, 1.5, 0), frame)
	box(rov, Vector3(1.4, 0.75, 2.0), Vector3(0, 0.8, 0), black)
	for x in [-0.8, 0.8]:
		beam(rov, Vector3(x, 0, -1.3), Vector3(x, 0, 1.3), 0.08, frame)
		for z in [-1.3, 1.3]:
			beam(rov, Vector3(x, 0, z), Vector3(x, 1.75, z), 0.055, frame)
	for x in [-0.85, 0.85]:
		for z in [-0.8, 0.8]:
			var thrust := CylinderMesh.new()
			thrust.top_radius = 0.22
			thrust.bottom_radius = 0.22
			thrust.height = 0.5
			var node := mesh(rov, thrust, black, Vector3(x, 0.7, z))
			node.rotation.x = PI / 2
	text(rov, "SURVEY ROV", Vector3(0, 1.75, 1.57), 30)


static func build_survey(parent: Node3D, survey: Dictionary) -> void:
	var sediment := material(Color("#817b63"), 0.0, 0.96)
	var noise := FastNoiseLite.new()
	noise.seed = 741
	noise.frequency = 0.065
	var texture := NoiseTexture2D.new()
	texture.width = 512
	texture.height = 512
	texture.noise = noise
	sediment.albedo_texture = texture
	sediment.uv1_triplanar = true
	sediment.uv1_scale = Vector3(0.2, 0.2, 0.2)
	var ground := mesh(parent, Geo.seabed_mesh(0.5), sediment, Vector3.ZERO)
	ground.create_trimesh_collision()
	mesh(parent, Geo.cable_mesh(), material(Color("#252b2a"), 0.15, 0.65), Vector3.ZERO)
	var net := material(Color("#bbb786"), 0.1)
	net.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh(parent, Geo.netting_mesh(survey["features"][1]), net, Vector3.ZERO)
	mesh(parent, Geo.abrasion_mesh(survey["features"][0]), material(Color("#b49c71"), 0.4, 0.35), Vector3.ZERO)
	mesh(parent, Geo.furrow_mesh(survey["features"][2]), material(Color("#626252")), Vector3.ZERO)
	mesh(parent, Geo.slide_lobe_mesh(survey["features"][3]), sediment, Vector3.ZERO)
	var random := RandomNumberGenerator.new()
	random.seed = 5107
	var rock := SphereMesh.new()
	rock.radius = 1
	rock.height = 2
	rock.radial_segments = 8
	rock.rings = 4
	var rocks := MultiMesh.new()
	rocks.transform_format = MultiMesh.TRANSFORM_3D
	rocks.mesh = rock
	rocks.instance_count = 180
	for index in rocks.instance_count:
		var x := random.randf_range(-34, 34)
		var z := random.randf_range(-34, 34)
		var scale := Vector3(random.randf_range(0.07, 0.4), random.randf_range(0.06, 0.22), random.randf_range(0.08, 0.4))
		rocks.set_instance_transform(index, Transform3D(Basis.IDENTITY.scaled(scale), Vector3(x, Seabed.height_at(x, z), z)))
	var node := MultiMeshInstance3D.new()
	node.multimesh = rocks
	node.material_override = material(Color("#747968"))
	parent.add_child(node)
	var dust := MultiMesh.new()
	dust.transform_format = MultiMesh.TRANSFORM_3D
	var speck := SphereMesh.new()
	speck.radius = 0.012
	speck.height = 0.024
	speck.radial_segments = 4
	speck.rings = 2
	dust.mesh = speck
	dust.instance_count = 1400
	for index in dust.instance_count:
		dust.set_instance_transform(index, Transform3D(Basis.IDENTITY, Vector3(random.randf_range(-34, 34), random.randf_range(-419, -402), random.randf_range(-34, 34))))
	var particles := MultiMeshInstance3D.new()
	particles.multimesh = dust
	particles.material_override = material(Color("#778e89"))
	parent.add_child(particles)
