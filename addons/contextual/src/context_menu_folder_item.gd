class_name ContextMenuFolderItem

const SUBMENU_SHIFT = 0.95

var __submenu: Control
var __timer: SceneTreeTimer

func _init(menu: ContextMenu, options={}) -> void:
  var name = Funk.option(options, 'name', '')
  var subtree = Funk.option(options, 'subtree', {})

  var menu_item_scene = load("uid://r4b2142dv5sp")

  var container = menu.container
  var item: Control = N.create_scene(menu_item_scene, container, container, name)

  var button: Button = N.get_child(item, Button)
  button.text = '{n}        '.format({n=name})

  var folder_depth = menu.depth

  var delay = 0.15
  var menu_shift = 8 # pixels
  button.mouse_entered.connect(func():
    if self.__timer and self.__timer.time_left:
      for conn in Array(self.__timer.timeout.get_connections()):
        self.__timer.timeout.disconnect(conn.callable)
    
    self.__timer = EditorUI.new().timer(delay)
    self.__timer.timeout.connect(func(): 
      if self.__submenu and is_instance_valid(self.__submenu) and menu.depth == folder_depth + 1:
        return

      while menu.depth > folder_depth:
        menu.close_current()

      # TODO: Should almost certainly double check the global position to see
      # if the menu should open on the left instead. But for now, assume it
      # should open to the right of the parent menu.
      var start_position = item.global_position + Vector2.RIGHT*item.size + Vector2.LEFT*menu_shift 
      var end_position = start_position + Vector2.RIGHT*menu_shift*2
      self.__submenu = menu.open_submenu(start_position, subtree, {tree_name=name})
      self.__submenu.modulate.a = 0;
      var tween = self.__submenu.create_tween()
      tween.set_parallel()
      tween.tween_property(self.__submenu, 'global_position', end_position, .2)\
        .set_ease(Tween.EASE_OUT)\
        .set_trans(Tween.TRANS_SPRING)
      
      tween.tween_property(self.__submenu, 'modulate:a', 1, .1)

    )
  )
  
  button.mouse_exited.connect(func():
    if self.__timer and self.__timer.time_left:
      for conn in Array(self.__timer.timeout.get_connections()):
        self.__timer.timeout.disconnect(conn.callable)

    self.__timer = EditorUI.new().timer(delay)
    self.__timer.timeout.connect(func():
      # if mouse is still inside menu, don't close.
      if EditorUI.new().is_mouse_over(self.__submenu):
        return

      if not self.__submenu:
        return

      var start_position = self.__submenu.global_position
      var end_position = start_position + Vector2.LEFT*menu_shift*2
      var close = func():
        menu.close_current()
        self.__submenu = null

      var tween = self.__submenu.create_tween()
      tween.set_parallel(true)
      tween.tween_property(self.__submenu, 'global_position', end_position, .1)\
        .set_ease(Tween.EASE_IN)\
        .set_trans(Tween.TRANS_CUBIC)

      tween.tween_property(self.__submenu, 'modulate:a', 0, .1)
      
      tween.set_parallel(false)
      tween.tween_callback(close)
    )
  )
