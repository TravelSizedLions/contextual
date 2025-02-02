@tool
class_name ContextualInputListener extends Control

signal on_editor_input

func _input(event: InputEvent) -> void:
  on_editor_input.emit(event)
