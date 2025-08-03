class_name Interactable extends Node


signal on_interacted(interactor: Node)
signal on_focus_changed(state: bool)

@export_group("Dependencies")
@export var mesh: MeshInstance3D
@export var highlight_material: StandardMaterial3D

@export_group("Settings")
@export var title: String = "TITLE UNSET"
@export var prompt: String = "PROMPT UNSET"


func _ready() -> void:
	#Incase we forget to add the mesh export.
	if mesh == null:
		for i in get_children():
			if i is MeshInstance3D:
				mesh = i

func interact_with(interactor: Node) -> void:
	if interactor == null: return
	on_interacted.emit(interactor)
	print(interactor.name + " interacted with " + name)

func set_focus(state = false) -> void:
	if mesh and highlight_material:
		mesh.material_overlay = highlight_material if state else null
	on_focus_changed.emit(state)
