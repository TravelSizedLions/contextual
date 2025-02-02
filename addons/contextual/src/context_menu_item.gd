@tool
class_name ContextMenuItem

var __timer: SceneTreeTimer

func _init(menu: ContextMenu, options={}):
  var name = Funk.option(options, 'name', '')
  var action = Funk.option(options, 'action', func (): pass)

  var menu_item_scene = load("uid://ceu8s4sk6bf6o")
  var container = menu.container
  var button: Button = N.get_child(
    N.create_scene(menu_item_scene, container, container, name), 
    Button	
  )

  var item_depth = menu.depth
  var delay = 0.3
  button.mouse_entered.connect(func():
    if self.__timer and self.__timer.time_left:
      for conn in Array(self.__timer.timeout.get_connections()):
        self.__timer.timeout.disconnect(conn.callable)

    self.__timer = EditorUI.new().timer(delay)
    self.__timer.timeout.connect(func(): 
      while menu.depth > item_depth: menu.close_current()
    )
  )

  button.mouse_exited.connect(func():
    if self.__timer and self.__timer.time_left:
      for conn in Array(self.__timer.timeout.get_connections()):
        self.__timer.timeout.disconnect(conn.callable)
  )

  button.button_down.connect(func(): 
    action.call()
    menu.close_all()
  )
  button.text = name
