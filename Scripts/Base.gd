extends Node

const player_camera_scene = preload("res://Scenes/playercamera.tscn")

@onready var screen_container: Control = $CenterContainer/GridContainer

var level_to_load: String = "res://Scenes/Map.tscn"
var first_subviewport: SubViewport = null
var level_node: Node2D = null

func _ready() -> void:
	_add_new_player_viewport(null)
	_update_viewport_size()

func _add_new_player_viewport(new_player_node: Area2D) -> void:
	var new_subviewportcontainer: SubViewportContainer = SubViewportContainer.new()
	var new_subviewport: SubViewport = SubViewport.new()
	new_subviewportcontainer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	new_subviewport.disable_3d = true
	
	var new_camera2d: Camera2D = player_camera_scene.instantiate()
	screen_container.add_child(new_subviewportcontainer)
	new_subviewportcontainer.add_child(new_subviewport)
	new_subviewport.add_child(new_camera2d)
	
	if first_subviewport:
		new_player_node.get_node("RemoteTransform2D").remote_path = new_camera2d.get_path()
		new_subviewport.world_2d = first_subviewport.world_2d
	else:
		level_node = load(level_to_load).instantiate()
		new_subviewport.add_child(level_node)
		first_subviewport = new_subviewport
		level_node.get_tree().get_nodes_in_group("player")[0].get_node("RemoteTransform2D").remote_path = new_camera2d.get_path()

"""
func _update_viewport_size() -> void:
	screen_container.columns = ceil(screen_container.get_child_count() / 2.0)
	for viewport_node in screen_container.get_children():
		var subviewport_node: SubViewport = viewport_node.get_child(0)
		var game_size: Vector2 = get_viewport().get_visible_rect().size
		subviewport_node.size.x = game_size.x / screen_container.columns
		subviewport_node.size.y = game_size.y / ceil(float(screen_container.get_child_count()) / float(screen_container.columns))
"""

func _update_viewport_size() -> void:
	screen_container.columns = 2  # fixed rows

	var count: int = screen_container.get_child_count()
	var rows: int = int(ceil(float(count) / 2.0))

	for viewport_node in screen_container.get_children():
		var subviewport_node: SubViewport = viewport_node.get_child(0)
		var game_size: Vector2 = get_viewport().get_visible_rect().size
		subviewport_node.size.x = game_size.x / 2.0
		subviewport_node.size.y = game_size.y / rows


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("AddPlayers"):
		var new_player: Area2D = load("res://Scenes/player.tscn").instantiate()
		new_player.player_id = screen_container.get_child_count()
		level_node.add_child(new_player)
		_add_new_player_viewport(new_player)
		_update_viewport_size()
		
	if Input.is_action_just_pressed("RemovePlayers"):
		var screen_to_remove: SubViewportContainer = screen_container.get_child(screen_container.get_child_count()-1)
		var player_to_remove: Area2D
		for i in level_node.get_tree().get_nodes_in_group("player"):
			if i.player_id == screen_container.get_child_count() - 1:
				player_to_remove = i
		screen_to_remove.free()
		player_to_remove.free()
		_update_viewport_size()
