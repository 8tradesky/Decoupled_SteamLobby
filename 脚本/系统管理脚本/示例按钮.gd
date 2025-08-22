extends UI按钮基类

# 示例：创建大厅按钮
func _init():
	按钮名称 = "create_lobby"
	启用状态列表 = [
		UIStateManager.UIState.MAIN_MENU,    # 在主菜单启用
		UIStateManager.UIState.LOBBY_LIST   # 在大厅列表也启用
	]
	禁用状态列表 = [
		UIStateManager.UIState.IN_LOBBY     # 在大厅内禁用
	]

func _按钮初始化() -> void:
	text = "创建大厅"
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	print("创建大厅按钮被点击")
	# 这里可以添加创建大厅的逻辑
	# 例如：事件总线.发射_创建大厅请求.emit()
