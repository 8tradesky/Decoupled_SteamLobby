extends Node



func _ready() -> void:
	# 若 MainController 已经就绪，则不要再等待它的 ready 信号（否则会卡住）
	await get_tree().process_frame
	
	# 使用新的注册系统配置UI界面
	
	await get_tree().process_frame
	# 初始进入主菜单
	MainController.切换到主菜单()

# 注册所有界面到UI状态管理器
