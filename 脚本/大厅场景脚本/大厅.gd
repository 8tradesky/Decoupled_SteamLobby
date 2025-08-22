extends UI界面基类

@onready var ui_main_menu: Control = $"大厅初始按钮约束框"
@onready var ui_lobby_list: Control = $"大厅房间列表界面"
@onready var ui_in_lobby: Control = $"聊天发送文本约束框"
@onready var ui_chat_interface: Control = $"聊天文本约束框"

func _ready() -> void:
	# 若 MainController 已经就绪，则不要再等待它的 ready 信号（否则会卡住）
	if not MainController.is_node_ready():
		await MainController.ready
	await get_tree().process_frame
	
	# 使用新的注册系统配置UI界面
	_注册所有界面()
	
	await get_tree().process_frame
	# 初始进入主菜单
	MainController.切换到主菜单()

# 注册所有界面到UI状态管理器
func _注册所有界面() -> void:
	var ui_state_manager := MainController.获取UI状态管理器()
	
	if ui_state_manager:
		print("正在注册UI界面到状态管理器...")
		
		# 注册主菜单界面 - 只在主菜单状态显示
		ui_state_manager.注册界面("主菜单界面", ui_main_menu, [
			UIStateManager.UIState.MAIN_MENU,
			UIStateManager.UIState.LOBBY_LIST
		])
		
		# 注册大厅列表界面 - 只在大厅列表状态显示
		ui_state_manager.注册界面("大厅列表界面", ui_lobby_list, [
			UIStateManager.UIState.LOBBY_LIST
		])
		
		# 注册大厅内界面 - 只在大厅内状态显示
		ui_state_manager.注册界面("大厅内界面", ui_in_lobby, [
			UIStateManager.UIState.IN_LOBBY
		])
		
		# 注册聊天界面 - 在大厅内和聊天界面状态都显示
		ui_state_manager.注册界面("聊天界面", ui_chat_interface, [
			UIStateManager.UIState.IN_LOBBY,
			UIStateManager.UIState.CHAT_INTERFACE
		])
		
		print("所有UI界面注册完成")
		
		# 注册按钮到状态管理器
		_注册所有按钮()
	else:
		print("UI状态管理器未找到，无法注册界面")

# 注册所有按钮到UI状态管理器
func _注册所有按钮() -> void:
	var ui_state_manager := MainController.获取UI状态管理器()
	
	if ui_state_manager:
		print("正在注册按钮到状态管理器...")
		
		# 获取按钮引用（假设这些按钮存在于场景中）
		# 现在这些代码都是无用的,到时候只有特定按钮会需要注册,比如主客机不同,或者职业不同时的各个按钮
		var 创建大厅按钮 = _获取按钮引用("创建大厅按钮")
		var 加入大厅按钮 = _获取按钮引用("加入大厅按钮")
		var 退出游戏按钮 = _获取按钮引用("退出游戏按钮")
		var 返回主菜单按钮 = _获取按钮引用("返回主菜单按钮")
		var 离开大厅按钮 = _获取按钮引用("离开大厅按钮")
		var 开始游戏按钮 = _获取按钮引用("开始游戏按钮")
		var 聊天输入框 = _获取按钮引用("聊天输入框")
		var 发送消息按钮 = _获取按钮引用("发送消息按钮")
		var 返回大厅按钮 = _获取按钮引用("返回大厅按钮")
		var 退出游戏按钮2 = _获取按钮引用("退出游戏按钮2")
		
		# 注册按钮并定义其启用状态
		if 创建大厅按钮:
			ui_state_manager.注册按钮("create_lobby", 创建大厅按钮, [
				UIStateManager.UIState.MAIN_MENU,
				UIStateManager.UIState.LOBBY_LIST
			])
		
		if 加入大厅按钮:
			ui_state_manager.注册按钮("join_lobby", 加入大厅按钮, [
				UIStateManager.UIState.MAIN_MENU,
				UIStateManager.UIState.LOBBY_LIST
			])
		
		if 退出游戏按钮:
			ui_state_manager.注册按钮("exit_game", 退出游戏按钮, [
				UIStateManager.UIState.MAIN_MENU
			])
		
		if 返回主菜单按钮:
			ui_state_manager.注册按钮("back_to_main", 返回主菜单按钮, [
				UIStateManager.UIState.LOBBY_LIST
			])
		
		if 离开大厅按钮:
			ui_state_manager.注册按钮("leave_lobby", 离开大厅按钮, [
				UIStateManager.UIState.IN_LOBBY
			])
		
		if 开始游戏按钮:
			ui_state_manager.注册按钮("start_game", 开始游戏按钮, [
				UIStateManager.UIState.IN_LOBBY
			])
		
		if 聊天输入框:
			ui_state_manager.注册按钮("chat_input", 聊天输入框, [
				UIStateManager.UIState.IN_LOBBY,
				UIStateManager.UIState.CHAT_INTERFACE
			])
		
		if 发送消息按钮:
			ui_state_manager.注册按钮("send_message", 发送消息按钮, [
				UIStateManager.UIState.IN_LOBBY,
				UIStateManager.UIState.CHAT_INTERFACE
			])
		
		if 返回大厅按钮:
			ui_state_manager.注册按钮("return_to_lobby", 返回大厅按钮, [
				UIStateManager.UIState.GAME_SCENE
			])
		
		if 退出游戏按钮2:
			ui_state_manager.注册按钮("quit_game", 退出游戏按钮2, [
				UIStateManager.UIState.GAME_SCENE
			])
		
		print("所有按钮注册完成")
	else:
		print("UI状态管理器未找到，无法注册按钮")

# 获取按钮引用的辅助方法
func _获取按钮引用(按钮路径: String) -> Control:
	# 这里需要根据实际的场景结构来获取按钮引用
	# 示例：return get_node_or_null(按钮路径)
	return null
