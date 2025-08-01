class_name Interactable extends Node


@export_group("Dependencies")
@export var mesh: MeshInstance3D

@export_group("Settings")
@export var title: String = "NOT SET"
@export var prompt: String = "NOT SET"

#This is a preload instead of export because it can freeze the game for a few frames if it isnt already loaded.
var highlight_material: StandardMaterial3D = preload("res://resources/materials/mat_interactable_highlight.tres")

func _ready() -> void:
	#Incase we forget to add the mesh export.
	if mesh == null:
		for i in get_children():
			if i is MeshInstance3D:
				mesh = i

func interact_with(interactor: Node) -> void:
	if interactor == null: return
	print(interactor.name + " interacted with " + name)

func set_focus(should_focus = false) -> void:
	if mesh:
		mesh.material_overlay = highlight_material if should_focus else null
