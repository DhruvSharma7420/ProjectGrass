extends Node

const player_camera_scene = preload("res://Scenes/playercamera.tscn")
const player_scene = preload("res://Scenes/player.tscn")

@onready var screen_container: Control = $CenterContainer/GridContainer

var level_to_load: String = "res://Scenes/Map.tscn"
var first_subviewport: SubViewport = null
var level_node: Node2D = null

# Minimap
var minimap_container: SubViewportContainer
var minimap_viewport: SubViewport
var minimap_camera: Camera2D

func _ready() -> void:
	_add_new_player_viewport(null)
	_update_viewport_size()
	_add_minimap()


func _add_new_player_viewport(new_player_node: CharacterBody2D) -> void:
	var new_subviewportcontainer: SubViewportContainer = SubViewportContainer.new()
	var new_subviewport: SubViewport = SubViewport.new()
	new_subviewportcontainer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	new_subviewport.disable_3d = true

	var new_camera2d: Camera2D = player_camera_scene.instantiate()
	screen_container.add_child(new_subviewportcontainer)
	new_subviewportcontainer.add_child(new_subviewport)
	new_subviewport.add_child(new_camera2d)

	if first_subviewport:
		# Connect player to camera
		if new_player_node:
			new_player_node.get_node("RemoteTransform2D").remote_path = new_camera2d.get_path()
		new_subviewport.world_2d = first_subviewport.world_2d
	else:
		# First player: load level
		level_node = load(level_to_load).instantiate()
		new_subviewport.add_child(level_node)
		first_subviewport = new_subviewport
		if level_node.get_tree().get_nodes_in_group("player").size() > 0:
			level_node.get_tree().get_nodes_in_group("player")[0].get_node("RemoteTransform2D").remote_path = new_camera2d.get_path()


func _update_viewport_size() -> void:
	screen_container.columns = 2  # fixed rows
	var count: int = screen_container.get_child_count()
	var rows: int = int(ceil(float(count) / 2.0))

	for viewport_node in screen_container.get_children():
		var subviewport_node: SubViewport = viewport_node.get_child(0)
		var game_size: Vector2 = get_viewport().get_visible_rect().size
		subviewport_node.size.x = game_size.x / 2.0
		subviewport_node.size.y = game_size.y / rows

func _add_minimap() -> void:
	# SubViewportContainer
	minimap_container = SubViewportContainer.new()
	add_child(minimap_container)
	minimap_container.anchor_left = 0.5
	minimap_container.anchor_right = 0.5
	minimap_container.anchor_top = 1.0
	minimap_container.anchor_bottom = 1.0
	minimap_container.offset_left = -(390/2)
	minimap_container.offset_top = -245    # height above bottom
	minimap_container.size = Vector2(390, 240)

	# SubViewport
	minimap_viewport = SubViewport.new()
	minimap_viewport.disable_3d = true
	minimap_viewport.size = minimap_container.size
	minimap_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	minimap_container.add_child(minimap_viewport)

	# Camera2D for minimap
	minimap_camera = Camera2D.new()
	minimap_camera.make_current()
	minimap_camera.position = Vector2(6441, 3984)  # map center
	minimap_camera.zoom = Vector2(0.03, 0.03)      # zoom out more for smaller viewport
	minimap_viewport.add_child(minimap_camera)

	# Share world_2d so all players appear
	if first_subviewport:
		minimap_viewport.world_2d = first_subviewport.world_2d



func _process(delta: float) -> void:
	if Input.is_action_just_pressed("AddPlayers"):
		var new_player: CharacterBody2D = player_scene.instantiate()
		new_player.player_id = screen_container.get_child_count()

		# Set collision so players ignore each other
		new_player.collision_layer = 1 << 1   # all players on layer 2
		new_player.collision_mask = 1 << 0    # collide only with world (layer 1)

		level_node.add_child(new_player)
		_add_new_player_viewport(new_player)
		_update_viewport_size()

	if Input.is_action_just_pressed("RemovePlayers"):
		var screen_to_remove: SubViewportContainer = screen_container.get_child(screen_container.get_child_count() - 1)
		var player_to_remove: CharacterBody2D
		for i in level_node.get_tree().get_nodes_in_group("player"):
			if i.player_id == screen_container.get_child_count() - 1:
				player_to_remove = i
		screen_to_remove.free()
		player_to_remove.free()
		_update_viewport_size()
