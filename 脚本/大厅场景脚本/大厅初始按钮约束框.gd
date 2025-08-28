extends UI界面基类

@onready var btn_create: Button = $"Panel/加入\\创建前按钮/创建大厅"
@onready var btn_join: Button = $"Panel/加入\\创建前按钮/加入大厅"
@onready var btn_exit: Button = $"Panel/加入\\创建前按钮/退出"

func _init():
	界面名称 = "主菜单界面"
	显示状态列表 =[
		UIStateManager.UIState.MAIN_MENU,
		UIStateManager.UIState.LOBBY_LIST
	]

func _界面初始化() -> void:
	btn_create.pressed.connect(_on_create_pressed)
	btn_join.pressed.connect(_on_join_pressed)
	btn_exit.pressed.connect(_on_exit_pressed)
	
	

func _on_create_pressed() -> void:
	MainController.创建大厅()

func _on_join_pressed() -> void:
	MainController.切换到大厅列表()
	MainController.请求大厅列表()

func _on_exit_pressed() -> void:
	get_tree().quit()
