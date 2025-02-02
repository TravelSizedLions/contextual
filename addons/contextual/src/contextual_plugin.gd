@tool
class_name ContextualPlugin extends EditorPlugin

var PLUGIN_NAME = "Contextual"

func _has_main_screen() -> bool: return false
func _get_plugin_name() -> String: return PLUGIN_NAME
func _get_plugin_icon(): return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
