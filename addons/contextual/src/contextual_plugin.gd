@tool
class_name ContextualPlugin extends EditorPlugin

var PLUGIN_NAME = "Contextual"

const SINGLETON_NAME = "InputListener"
const SINGLETON_PATH = "res://addons/contextual/input_listener.gd"

func _enter_tree() -> void:
  add_autoload_singleton(SINGLETON_NAME, SINGLETON_PATH)

func _exit_tree() -> void:
  remove_autoload_singleton(SINGLETON_NAME)

func _has_main_screen() -> bool: return false
func _get_plugin_name() -> String: return PLUGIN_NAME
func _get_plugin_icon(): return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
