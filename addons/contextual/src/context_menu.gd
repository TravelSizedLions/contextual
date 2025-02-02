@tool
class_name ContextMenu

var __ui = EditorUI.new()
var __menu_scene: PackedScene
var item_provider: Callable = func(): return {}

var __open_condition: Callable = func(): return true
var __open_menus: Array[Control] = []
var __editor_colors = EditorColorUtils.new()

var __tree = {}

var container: Control:
  get: return N.get_child(__open_menus[-1], VBoxContainer) if is_open() else null

var root: Control:
  get: return __open_menus[-1] if is_open() else null

var global_position: Vector2:
  get: return __open_menus[0].global_position if is_open() else -Vector2.INF

var depth: int:
  get: return __open_menus.size()

func _init(options = {}) -> void:
  __menu_scene = load('uid://bw8i8fpe2b2c6')
  __open_condition = Funk.option(options, 'open_condition', __open_condition)
  item_provider = Funk.option(options, 'item_provider', item_provider)
  InputListener.on_editor_input.connect(self.handle_gui_event)

func open_at(global_pos: Vector2):
  if not __open_menus.size():
    __tree = item_provider.call()
    open_submenu(global_pos, __tree)

  while __open_menus.size() > 1: close_current()
  __open_menus[0].global_position = global_pos

func open_submenu(position: Vector2, subtree: Dictionary, options={}):
  var parent = Funk.option(options, 'parent', __ui.editor)
  var tree_name = Funk.option(options, 'tree_name', "context_menu_root")
  
  # create a new empty submenu and color it
  __open_menus.append(N.create_scene(__menu_scene, parent, parent, tree_name))
  var menu: Control = __open_menus[-1]
  var stylebox: StyleBox = menu.get_theme_stylebox("panel").duplicate()
  stylebox.bg_color = __editor_colors.primary_color_lightened(2)
  menu.add_theme_stylebox_override("panel", stylebox)

  # add items
  for key in subtree:
    var value = subtree[key]
    if typeof(value) == TYPE_DICTIONARY:
      ContextMenuFolderItem.new(self, {name=key, subtree=value})
    else:
      ContextMenuItem.new(self, {name=key, action=value})
  
  # reposition
  menu.global_position = position
  return menu

func is_open():
  return __open_menus.size() > 0

func close_all():
  while is_open(): close_current()
  __tree = null

func close_current():
  __open_menus.pop_back().queue_free()


func handle_gui_event(event: InputEvent):
  if event is InputEventMouseButton:
    __mouse_event(event)

func __mouse_event(mouse_event: InputEventMouseButton):
  if mouse_event.pressed:
    match mouse_event.button_index:
      MOUSE_BUTTON_LEFT: __left_click(mouse_event)
      MOUSE_BUTTON_RIGHT: __right_click(mouse_event)
      _: close_all()

func __left_click(mouse_event: InputEventMouseButton):
  for menu in __open_menus:
    if N.is_inside(mouse_event.global_position, menu):
      return
  
  close_all()

func __right_click(mouse_event: InputEventMouseButton):
  if __open_condition.call():
    open_at(mouse_event.global_position)

func has_option(path: String):
  var opt = get_option(path)
  return opt != null and typeof(opt) == TYPE_CALLABLE

func get_option(path: String):
  if !is_open():
    return null

  var parts = Array(path.split('/'))
  var cur_node = __tree

  while not parts.is_empty():
    var part = parts.pop_front()
    if part not in cur_node:
      return null
    
    cur_node = cur_node[part]

  return cur_node;

func select_option(path: String):
  var opt = get_option(path)
  if opt == null:
    push_warning('Option "{p}" does not exist in menu'.format({p=path}))
    return

  if typeof(opt) == TYPE_DICTIONARY:
    push_warning('Option "{p}" is a subfolder, not an option'.format({p=path}))
    return

  if typeof(opt) != TYPE_CALLABLE:
    push_error('Option "{p}" is a completely unexpected type "{t}." It should be a Callable, you fool!'.format({
      p=path,
      t=type_string(typeof(opt))
    }))
  
  opt.call()
  close_all()

static func entrees_to_tree(entries: Dictionary) -> Dictionary:
  var handle_entry = func(path, item, tree):
    if not '/' in path:
      tree[path] = item
      return tree

    var parts = Array(path.split('/'))
    var cur_tree = tree
    while parts.size() > 1:
      var part = parts.pop_front()
      if part not in cur_tree:
        cur_tree[part] = {}
      
      cur_tree = cur_tree[part]

    cur_tree[parts.pop_front()] = item	
    return tree

  var tree = {}
  for path in entries:
    tree = handle_entry.call(path, entries[path], tree)

  return tree
