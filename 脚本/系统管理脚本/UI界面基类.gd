class_name UI界面基类
extends Control

# UI状态管理器引用
var UI状态管理器: UIStateManager

# 界面名称 - 子类需要重写
var 界面名称: String = "未命名界面"

# 显示状态列表 - 子类需要重写
var 显示状态列表: Array[UIStateManager.UIState] = []

# 是否自动注册 - 子类可以设置为false来禁用自动注册
var 自动注册: bool = true

func _ready() -> void:
	await get_tree().process_frame
	
	# 获取UI状态管理器引用
	UI状态管理器 = MainController.ui_state_manager
	
	# 自动注册到UI状态管理器
	if 自动注册:
		_注册到UI状态管理器()
	
	# 调用子类的初始化方法
	_界面初始化()

# 注册到UI状态管理器
func _注册到UI状态管理器() -> void:
	if UI状态管理器 and 界面名称 != "未命名界面":
		UI状态管理器.注册界面(界面名称, self, 显示状态列表)
		print("界面 '%s' 已自动注册到UI状态管理器" % 界面名称)
	else:
		print("警告: UI状态管理器未找到或界面名称未设置，无法注册界面")

# 手动注册界面（如果自动注册被禁用）
func 手动注册界面() -> void:
	_注册到UI状态管理器()

# 取消注册界面
func 取消注册界面() -> void:
	if UI状态管理器 and UI状态管理器.界面已注册(界面名称):
		UI状态管理器.取消注册界面(界面名称)
		print("界面 '%s' 已从UI状态管理器取消注册" % 界面名称)

# 更新显示规则
func 更新显示规则(新显示规则: Array[UIStateManager.UIState]) -> void:
	显示状态列表 = 新显示规则
	if UI状态管理器:
		UI状态管理器.更新界面显示规则(界面名称, 新显示规则)

# 子类需要重写的方法 - 界面初始化
func _界面初始化() -> void:
	pass

# 当节点被移除时，自动取消注册
func _exit_tree() -> void:
	取消注册界面()

# 获取当前UI状态
func 获取当前UI状态() -> UIStateManager.UIState:
	if UI状态管理器:
		return UI状态管理器.获取当前状态()
	return UIStateManager.UIState.INITIALIZED

# 检查是否在特定状态
func 是否在状态(状态: UIStateManager.UIState) -> bool:
	if UI状态管理器:
		return UI状态管理器.是否在状态(状态)
	return false

# 切换到特定状态
func 切换到状态(状态: UIStateManager.UIState) -> void:
	if UI状态管理器:
		UI状态管理器.切换到状态(状态)
