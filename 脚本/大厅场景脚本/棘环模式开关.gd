extends UI界面基类

@onready var 棘环模式: CheckButton = $棘环模式
func _init():
	界面名称 = "棘环模式开关"
	显示状态列表 = [
			UIStateManager.UIState.MAIN_MENU,
			UIStateManager.UIState.LOBBY_LIST,
			UIStateManager.UIState.IN_LOBBY,
			UIStateManager.UIState.CHAT_INTERFACE
		]

func _界面初始化() -> void:
	if not MainController.is_node_ready():
		await MainController.ready
	await get_tree().process_frame
	棘环模式.toggled.connect(_on_棘环模式_按下)
	
func _on_棘环模式_按下(已启用棘环模式:bool):
	EventBus.发射_启用棘环模式(已启用棘环模式)
