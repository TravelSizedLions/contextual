class_name ContextMenuTests extends TDTest

var menu: ContextMenu

func open_menu():
  menu.open_at(Vector2.ZERO)

func test_drive():
  before_each(func():
    var MockEditorSettings = mock(EditorSettings)
    MockEditorSettings.get_setting.returns(Color('#fff'))

    var MockEditorInterface = mock(EditorInterface)
    MockEditorInterface.get_base_control.returns(autofree(VBoxContainer.new()))
    MockEditorInterface.get_editor_settings.returns(MockEditorSettings.new())

    menu = ContextMenu.new()
    menu.__ui.__editor = MockEditorInterface.new()

    # silence static warning
    TDLogger.errors_only(func():
      var MockEditorColorsUtil = mock(EditorColorUtils)
      MockEditorColorsUtil.primary_color_lightened.returns(Color('#fff'))
      menu.__editor_colors = MockEditorColorsUtil.new()
    )
  )

  after_each(func():
    menu.close_all()	
  )

  group('open and close', func():
    test('menu is not open by default', func(): 
      assert_false(menu.is_open())
    )

    test('open_at() opens the context menu at the correct position', func():
      var pos = Vector2(999, 111)
      menu.open_at(pos)
      assert_true(menu.is_open())
      assert_equal(menu.root.global_position, pos)
    )

    test('right clicking opens the menu', func():
      var pos = Vector2(999, 111) 
      var mouse_event = TDMouse.right_click(pos)

      assert_false(menu.is_open())
      menu.handle_gui_event(mouse_event)
      assert_true(menu.is_open())
      assert_equal(menu.global_position, pos)
    )

    test('right clicking opens the menu at a new position', func():
      var pos1 = Vector2(1, 1)
      var pos2 = Vector2(2, 2)
      assert_false(menu.is_open())
      menu.handle_gui_event(TDMouse.right_click(pos1))
      assert_true(menu.is_open())
      assert_equal(menu.global_position, pos1)

      menu.handle_gui_event(TDMouse.right_click(pos2))
      assert_true(menu.is_open())
      assert_equal(menu.global_position, pos2)	
    )

    test('right clicking with a submenu open closes the submenu and moves the root menu', func():
      var pos1 = Vector2(1, 1)
      var pos2 = Vector2(2, 2)
      var pos3 = Vector2(3, 3)

      menu.open_at(pos1)
      menu.open_submenu(pos2, {})
      assert_equal(menu.depth, 2)
      assert_true(menu.is_open())
      menu.handle_gui_event(TDMouse.right_click(pos3))
      assert_true(menu.is_open())
      assert_equal(menu.depth, 1)
      assert_equal(menu.global_position, pos3)
    )

    test('left clicking outside the menu closes the menu', func():
      assert_false(menu.is_open())
      open_menu()
      assert_true(menu.is_open())
      menu.handle_gui_event(TDMouse.click(Vector2(-1, -1)))
      assert_false(menu.is_open())
    )

    test('close_all() closes the menu', func():
      assert_false(menu.is_open())
      open_menu()
      assert_true(menu.is_open())
      menu.close_all()
      assert_false(menu.is_open())
    )

    test('close_all() does not implode if the menu is already closed', func():
      assert_false(menu.is_open())
      menu.close_all()
      assert_false(menu.is_open())	
    )
  )

  group('item registration and behavior', func():
    test('items from an item provider appear in the menu', func():
      menu.item_provider = func():
        return {
          'test 1': func(): pass,
          'test 2': func(): pass
        }	
      
      open_menu()
      assert_true(menu.is_open())
      assert_true(menu.has_option('test 1'))
      assert_true(menu.has_option('test 2'))
    )

    test('submenus register properly', func(): 
      menu.item_provider = func():
        return {
          'sub': {
            'menu': {
              'item': func(): pass
            }
          }
        }
      
      open_menu()
      assert_true(menu.is_open())
      assert_false(menu.has_option('sub'))
      assert_false(menu.has_option('sub/menu'))
      assert_false(menu.has_option('item'))
      assert_true(menu.has_option('sub/menu/item'))
    )

    test('items from an item provider perform an action when selected', func():
      var ref = {passed = false}
      menu.item_provider = func():
        return {
          'do thing': func(): ref.passed = true
        }
      
      open_menu()
      menu.select_option('do thing')
      assert_true(ref.passed)
    )
  )
